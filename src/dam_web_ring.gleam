import domain_list
import gleam/erlang/process
import server

pub fn main() -> Nil {
  let assert Ok(#(indexes, domains)) =
    domain_list.parse_domain_file("domains.txt")
  let assert Ok(_) = server.start_server(domains, indexes)
  process.sleep_forever()
}
