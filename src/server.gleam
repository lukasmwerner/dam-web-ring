import current_page
import domain_list
import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/otp/static_supervisor as supervisor
import gleam/string
import mist.{type Connection, type ResponseData}
import redirect.{redirect}

pub fn start_server(indexes: Dict(String, Int), domains: Dict(Int, String)) {
  let not_in_ring =
    response.new(404)
    |> response.set_body(
      mist.Bytes(bytes_tree.from_string("Site not in Webring.")),
    )
  let not_found =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let server =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["list"] -> display(domains)
        ["prev"] -> {
          let domain =
            { current_page.index(req, indexes) - 1 }
            |> domain_list.from_index(domains)
          case domain != "" {
            True -> redirect(domain)
            False -> not_in_ring
          }
        }

        ["next"] -> {
          let domain =
            { current_page.index(req, indexes) + 1 }
            |> domain_list.from_index(domains)

          case domain != "" {
            True -> redirect(domain)
            False -> not_in_ring
          }
        }

        _ -> not_found
      }
    }
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(3000)
    |> mist.supervised

  let assert Ok(_) =
    supervisor.new(strategy: supervisor.OneForOne)
    |> supervisor.restart_tolerance(intensity: 100, period: 60)
    |> supervisor.add(server)
    |> supervisor.start
}

fn display(domains: Dict(Int, String)) -> Response(ResponseData) {
  let header = "<h1>Dam Web Ring!</h1>\n" <> "<hr>"
  let html_list =
    "<ul>\n"
    <> {
      domains
      |> dict.to_list
      |> list.map(fn(domain) -> String {
        "<li><a href=\"https://" <> domain.1 <> "\">" <> domain.1 <> "</li>\n"
      })
    }
    |> string.join("")
    <> "</ul>\n"

  response.new(200)
  |> response.set_header("Content-Type", "text/html")
  |> response.set_body(
    bytes_tree.from_string(header <> html_list) |> mist.Bytes,
  )
}
