import gleam/bytes_tree
import gleam/http/response
import mist

pub type Redirect {
  Redirect(url: String)
}

pub fn redirect(to url: String) {
  { "https://" <> url }
  |> response.redirect
  |> response.set_body(bytes_tree.new() |> mist.Bytes)
}
