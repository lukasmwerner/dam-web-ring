import current_page
import domain_list
import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import redirect.{redirect}

pub fn start_server(indexes: Dict(String, Int), domains: Dict(Int, String)) {
  let not_found =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  fn(req: Request(Connection)) -> Response(ResponseData) {
    case request.path_segments(req) {
      ["prev"] ->
        { current_page.index(req, indexes) - 1 }
        |> domain_list.from_index(domains)
        |> redirect

      ["next"] ->
        { current_page.index(req, indexes) + 1 }
        |> domain_list.from_index(domains)
        |> redirect

      _ -> not_found
    }
  }
  |> mist.new
  |> mist.bind("0.0.0.0")
  |> mist.port(3000)
  |> mist.start
}
