#' @export
email_body_template <- \(
  heading = "",
  salutation,
  pre_body_text = "",
  body,
  footer
) {
  paste0(
    '<div>
    <div class="x_10659417split-background" style="background: whitesmoke; padding: 40px 0; width: 100%">
        <div class="x_10659417container" style="width: 100%; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #fff; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1)">
            <div class="x_10659417logo" style="text-align: center; margin-bottom: 20px">
                <img src="https://quickstudy.co.ke/candidate/logo/logo_full.png" alt="CANDIDATE LOGO" style="max-width: 300px; height: auto">
            </div>
            <h1 style="font-size: 20px; color: #333; font-family: Montserrat, sans-serif;">
                <strong style="color: #003366;">', heading, "</strong>
            </h1>",
    salutation,
    '<p style="font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;">',
    pre_body_text,
    body,
    '</p>
            <div class="x_10659417footer" style="font-size: 14px; color: #777; margin-top: 30px;">
                <p style="color: #444; font-family: Montserrat, sans-serif;">',
    footer,
    "</p>
            </div>
        </div>
    </div>
</div>"
  )
}

#' @export
welcome_body <- \(user_id) {
  paste0(
    '
<div style="font-family: Montserrat, sans-serif; font-size: 16px; line-height: 1.6; color: #333;">
    <p style="margin: 0 0 10px;">
        We are glad for you joining us! If you have any inquiries, complaints, or suggestions, please do not hesitate to reach out to us.
    </p>
    <p style="margin: 0 0 10px;">
        You can call us at <strong>0111672464</strong>, or visit our <a href="https://quickstudy.co.ke/candidate/" target="_blank" style="color: #007BFF; text-decoration: none;">website</a> to create a ticket for assistance. Always reference your <strong>CANDIDATE ID', user_id, '</strong> when contacting us.
    </p>
    <p style="margin: 0 0 10px;">
        We look forward to a long and rewarding experience together.
    </p>
</div>'
  )
}

#' @export
internal_email_footer <- "Happy working,<br>
                          Candidate <b>Technical</b> Team"

#' @export
external_email_footer <- "Regards,<br>
                          Your <b>CANDIDATE</b> Team"
#' @export
email_salutation <- \(first_name) {
  paste0(
    "<p style='font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;'>Hello <strong>",
    first_name,
    "</strong>,</p>"
  )
}

#' @export
updated_request_body <- \(request_id, request_status) {
  paste0(
    '<p style="font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;">
         We wanted to inform you that the status of your <strong>',
    request_id,
    "</strong> has been updated to <strong>",
    request_status,
    '</strong>.
       </p>
       <p style="font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;">
         You can monitor the progress of your request by visiting your
         <a href="https://quickstudy.co.ke/candidate/" target="_blank" style="color: #003366; text-decoration: underline;">teacher portal</a>.
       </p>
       <p style="font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;">
         If you have any questions or need further assistance, please don\'t hesitate to contact our support team.
       </p>'
  )
}

#' @export
updated_payments_body <- function(user, ticket_no, amount, payment_status) {
  paste0(
    '<div style="font-family: Montserrat, sans-serif; margin: 20px auto; max-width: 600px; border-radius: 8px; ',
    'box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); background: #f9f9f9; overflow: hidden;">',
    '  <div style="background: #003366; color: #fff; padding: 20px; text-align: center;">',
    '    <div style="text-align: center; margin-bottom: 20px;">',
    '      <img src="https://quickstudy.co.ke/candidate/logo/full_logo_white.png" alt="CANDIDATE LOGO" ',
    'style="max-width: 300px; height: auto;">',
    "    </div>",
    '    <h2 style="margin: 0; font-size: 24px;">Payment Notification</h2>',
    "  </div>",
    '  <div style="padding: 20px;">',
    '    <p style="font-size: 16px; line-height: 1.6;">Dear ', user, ",</p>",
    '    <p style="font-size: 16px; line-height: 1.6;">Please find attached the latest status on your payment:</p>',
    '    <ul style="list-style: none; padding: 0; font-size: 16px; line-height: 1.6;">',
    "      <li><strong>Ticket ID:</strong> ", ticket_no, "</li>",
    "      <li><strong>Amount Paid:</strong> KES ", format(amount, big.mark = ","), "</li>",
    "      <li><strong>Payment Status:</strong> ",
    '        <span style="color: ',
    ifelse(payment_status == "APPROVED", "#28a745",
      ifelse(payment_status == "DECLINED", "#dc3545", "#ffc107")
    ),
    ';">', payment_status, "</span>",
    "      </li>",
    "    </ul>",
    '    <p style="font-size: 16px; line-height: 1.6;">For more details, please log in to your account and check the payment section.</p>',
    "  </div>",
    '  <div style="background: #f1f1f1; padding: 10px 20px; text-align: center;">',
    '    <p style="margin: 0; font-size: 14px; color: #777;">Thank you for choosing Candidate!</p>',
    "  </div>",
    "</div>"
  )
}

#' @export
published_content_body <- \(user, teacher_name, grade, learning_area, topic, sub_topic) {
  paste0(
    '<div style="font-family: Montserrat, sans-serif; margin: 20px auto; max-width: 600px; border-radius: 8px; ',
    'box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); background: #f9f9f9; overflow: hidden;">',
    '  <div style="background: #003366; color: #fff; padding: 20px; text-align: center;">',
    '    <div style="text-align: center; margin-bottom: 20px;">',
    '      <img src="https://quickstudy.co.ke/candidate/logo/full_logo_white.png" alt="CANDIDATE LOGO" ',
    'style="max-width: 300px; height: auto;">',
    "    </div>",
    '    <h2 style="margin: 0; font-size: 24px;">New Content</h2>',
    "  </div>",
    '  <div style="padding: 20px;">',
    '    <p style="font-size: 16px; line-height: 1.6;">Dear ', user, ",</p>",
    '    <p style="font-size: 16px; line-height: 1.6;">Please find attached details of a new content for you: </p>',
    '    <ul style="list-style: none; padding: 0; font-size: 16px; line-height: 1.6;">',
    "      <li><strong>Teacher:</strong> ", teacher_name, "</li>",
    "      <li><strong>Grade:</strong> ", grade, "</li>",
    "      <li><strong>Learning Area:</strong> ", learning_area, "</li>",
    "      <li><strong>Topic:</strong> ", topic, "</li>",
    "      <li><strong>Sub Topic:</strong> ", sub_topic, "</li>",
    "    </ul>",
    '    <p style="font-size: 16px; line-height: 1.6;">Please log into your Candidate account and have a happy learning.</p>',
    "  </div>",
    '  <div style="background: #f1f1f1; padding: 10px 20px; text-align: center;">',
    '    <p style="margin: 0; font-size: 14px; color: #777;">Thank you for choosing Candidate!</p>',
    "  </div>",
    "</div>"
  )
}
