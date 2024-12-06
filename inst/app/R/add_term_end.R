#' Add reset payment rows for each student
#' @param term_end_date String. The end date for the current term.
#' @return An integer indicating the number of rows affected.
#' @export
add_term_end <- function(term_end_date) {
  # Create the SQLite connection
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn))

  # Update the term_end_date and term_label
  query_end_date <- "UPDATE administrator
                     SET value = :new_end_date
                     WHERE input_col = 'term_end_date'"
  result_end_date <- DBI::dbExecute(
    conn,
    query_end_date,
    params = list(new_end_date = as.character(term_end_date))
  )

  query_term_label <- "UPDATE administrator
                       SET value = :new_term_label
                       WHERE input_col = 'term_label'"

  current_month <- toupper(format(Sys.Date(), "%b"))
  end_month <- toupper(format(as.Date(term_end_date), "%b"))
  current_year <- format(as.Date(term_end_date), "%Y")
  term_label <- paste(current_month, end_month, current_year, sep = "-")

  result_term_label <- DBI::dbExecute(
    conn,
    query_term_label,
    params = list(new_term_label = term_label)
  )

  insert_reset_query <- "
  INSERT INTO payments (ticket_id, user_id, code, amount, balance, total, number, time, term, status)
  SELECT
    'RESET-ID',  -- Reset ticket ID for the new row
    user_id,  -- The user_id from the most recent payment record
    NULL AS code,  -- No code for reset payment
    CASE
      WHEN balance < 0 AND status = 'APPROVED' THEN -1 * balance  -- If the balance is negative and the transaction is approved, multiply by -1
      WHEN status = 'APPROVED' THEN balance  -- If the status is approved, use the balance as amount
      ELSE 0  -- If no approved transaction, reset with 0
    END AS amount,  -- Amount for the reset payment based on the approval status
    CASE
      WHEN balance < 0 AND status = 'APPROVED' THEN 1500 - (-1 * balance)  -- Balance is 1500 minus the amount if the transaction is approved
      WHEN status = 'APPROVED' THEN 1500 - balance  -- Balance is 1500 minus the amount if the transaction is approved
      ELSE 0  -- If no approved transaction, reset with 0
    END AS balance,  -- Balance is 1500 minus the amount
    CASE
      WHEN balance < 0 AND status = 'APPROVED' THEN -1 * balance  -- Set total equal to the amount for approved transactions
      WHEN status = 'APPROVED' THEN balance  -- Set total equal to the balance for approved transactions
      ELSE 0  -- If no approved transaction, reset with 0
    END AS total,  -- Total is equal to the amount for approved transactions
    number,  -- Keep the original number
    :reset_time AS time,  -- Use the provided reset time
    :new_term_label AS term,  -- Use the new term label
    'RESET' AS status  -- Set the status to 'RESET'
  FROM payments
  WHERE user_id IN (
    SELECT user_id
    FROM payments
    WHERE status = 'APPROVED'
    ORDER BY time DESC
    LIMIT 1
  )
  OR NOT EXISTS (
    SELECT 1
    FROM payments
    WHERE status = 'APPROVED'
    AND user_id = payments.user_id
  )
"
  reset_time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")

  reset_result <- DBI::dbExecute(
    conn,
    insert_reset_query,
    params = list(
      reset_time = reset_time,
      new_term_label = term_label
    )
  )
  result_end_date + result_term_label + reset_result
}
