---
title: ""
output: 
 html_document
params:
 data: NA
 comment: NA
---

```{=html}
<style type="text/css">
  body{
  font-family: candara;
  font-size: 12px;
}
  h1{
  font-size: 17px;
  font-weight: 600;
}
.column-container {
  display: flex;
}

.column {
  flex: 1; /* Equal width columns */
  padding: 0px;
}
.table {
  border-collapse: collapse;
  border: none;
  margin-bottom: 5px;
}
.h1, .h2, .h3, h1, h2, h3 {
    margin-top: 5px;
    margin-bottom: 5px;
}
.table {
    margin-bottom: 0px;
}
p {
    margin: 0px 0 5px;
}
.table th, .table td {
  border: none;
}
.table>tbody>tr>td, .table>tbody>tr>th, .table>tfoot>tr>td, .table>tfoot>tr>th, .table>thead>tr>td, .table>thead>tr>th {
    border-top: 0px solid #fff;
}
hr {
    margin-top: 0px;
    margin-bottom: 5px;
    border: 0;
    border-top: 0.5px solid #0000001a;
}
.table>thead>tr>th {
    vertical-align: bottom;
    border-bottom: 1px solid #0000;
}
.stamp-container {
  position: absolute;
  margin-top: -190px;
  margin-left: 450px;
}
.sign-container {
  position: absolute;
  margin-top: -170px;
  margin-left: 390px;
}
</style>

<p>

<u><strong>FINANCIAL RECORDS</strong></u>

<p>

</div>

<p>Please find attached the CANDIDATE finacial records:</p>

```{r, echo=FALSE}
library(knitr)
library(kableExtra)
params$data %>%
  kable("html") %>%
  kable_styling("striped", full_width = FALSE)

```

**COMMENT**

This is a **CONFIDENTIAL DOCUMENT**.

