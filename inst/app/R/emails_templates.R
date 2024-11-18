email_body_template <- \(salutation, email_body, email_footer) {
  paste0(
    '<!DOCTYPE html><html><head><style>
body {
  font-family: Montserrat, sans-serif;
  color: #333333;
  margin: 0;
  padding: 0;
  background-color: #f4f4f4;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}
.split-background {
  background: whitesmoke;
  padding: 40px 0;
  width: 100%;
}
.container {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  background-color: #ffffff;
    border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
.logo {
  text-align: center;
  margin-bottom: 20px;
}
.logo img {
  max-width: 300px;
  height: auto;
}
h1 {
  font-size: 20px;
  color: #333333;
}
p {
  font-size: 16px;
  line-height: 1.6;
  margin: 16px 0;
}
a {
  color: white !important;
    text-decoration: none;
}
.button {
  display: inline-block;
  padding: 10px 20px;
  font-size: 16px;
  color: white;
  background-color: #163142;
  border-radius: 5px;
  text-align: center;
  text-decoration: none;
  margin-top: 20px;
}
.footer {
  font-size: 14px;
  color: #777777;
  margin-top: 30px;
}
</style></head><body>
<div class="split-background">
<div class="container">
<div class="logo">
<img src="https://ndekejefferson.shinyapps.io/candidate/_w_70987ccd/logo/logo_full.png" alt="CANDIDATE LOGO">
</div>
 <h1>Database Back-up report</h1>',
    salutation,
    email_body,
    email_footer
  )
}


#' @export
admin_report_body <-
  "<p>Attached are CANDIDATE records:</p>
    <ul>
    <li>Schools</li>
    <li>Teachers</li>
    <li>Students</li>
    <li>Content</li>
    <li>Views</li>
    <li>Payments</li>
    <li>Requests</li>
    </ul> "

#' @export
admin_email_footer <- '<div class="footer">
    <p>Happy working,<br>Candidate Technical Team</p>
    </div>
    </div>
    </div>
    </body>
    </html>'
