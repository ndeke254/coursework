dashboard_user_content <- argonRow(
    argonColumn(
        width = 12,
       argonProfile(
           title = textOutput("role"),
           subtitle = textOutput("full_name"),
           src = "https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png",
           stats = argonProfileStats(
               argonProfileStat(
                   value = textOutput("id"),
                   description = "ID"
               )
           ),
           textOutput("email"),
           textOutput("school"),
            uiOutput("paid_badge")
       )
    )
)