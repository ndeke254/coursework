#' @export
email_body_template <- \(
    heading,
    salutation,
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
welcome_body <- 'We are glad for you joining us. For any inquiries, complaints, or suggestions, kindly visit our
                <a href="https://quickstudy.co.ke/candidate/" target="_blank">website</a> and create a ticket to contact us. Reference your <b>CANDIDATE ID</b> always.
                <p style="font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;">
                We look forward to a long and wonderful experience together.
            </p>'

#' @export
internal_email_footer <- "Happy working,<br>
Candidate Technical</p> Team"

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
