#' Parse an HTML page.
#'
#' html is deprecated: please use \code{read_html}() instead.
#'
#' @param x A url, a local path, a string containing html, or a response from
#'   an httr request.
#' @param ... If \code{x} is a URL, additional arguments are passed on to
#'   \code{\link[httr]{GET}()}.
#' @param encoding Specify encoding of document. See \code{\link{iconvlist}()}
#'   for complete list. If you have problems determining the correct encoding,
#'   try \code{\link[stringi]{stri_enc_detect}}
#' @keywords deprecated
#' @export
#' @examples
#' # From a url:
#' google <- read_html("http://google.com", encoding = "ISO-8859-1")
#' google %>% xml_structure()
#' google %>% html_nodes("div")
#'
#' # From a string: (minimal html 5 document)
#' # http://www.brucelawson.co.uk/2010/a-minimal-html5-document/
#' minimal <- read_html("<!doctype html>
#'   <meta charset=utf-8>
#'  <title>blah</title>
#'  <p>I'm the content")
#' minimal
#' minimal %>% xml_structure()
#'
#' # From an httr request
#' google2 <- read_html(httr::GET("http://google.com"))
html <- function(x, ..., encoding = "") {
  .Deprecated("read_html")
  xml2::read_html(x, ..., encoding = encoding)
}

#' @inheritParams xml2::read_xml
#' @export
#' @rdname html
read_xml.response <- function(x, ..., encoding = "", as_html = FALSE) {
  httr::stop_for_status(x)
  encoding <- encoding %||% default_encoding(x)

  xml2::read_xml(httr::content(x, "raw"), encoding = encoding, base_url = x$url,
    as_html = as_html)
}

default_encoding <- function(x) {
  type <- httr::headers(x)$`Content-Type`
  if (is.null(type)) return(NULL)

  media <- httr::parse_media(type)
  media$params$charset
}

#' @importFrom xml2 read_xml
#' @export
#' @rdname html
read_xml.session <- function(x, ..., as_html = FALSE) {
  if (exists("cached", envir = x$html)) {
    return(x$html$cached)
  }

  if (!is_html(x)) {
    stop("Current page doesn't appear to be html.", call. = FALSE)
  }

  read_xml.response(x$response, ..., as_html = as_html)
}
