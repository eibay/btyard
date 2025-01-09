defmodule BtyardWeb.SoapController do
  use BtyardWeb, :controller

  import SweetXml

  @wsdl_path "priv/static/wsdl/service.wsdl"

  # Serve the WSDL file
  def wsdl(conn, _params) do
    wsdl_content = File.read!(@wsdl_path)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, wsdl_content)
  end

  # Handle SOAP requests
  def handle_request(conn, _params) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    # Parse the incoming SOAP request XML
    case parse_soap_request(body) do
      {:ok, %{"userId" => user_id}} ->
        user = get_user(user_id)

        # Generate the SOAP-compliant response
        response = build_soap_response(user)

        conn
        |> put_resp_content_type("text/xml")
        |> send_resp(200, response)

      {:error, reason} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(400, "Invalid SOAP request: #{reason}")
    end
  end

  # Helper function to parse the SOAP request
  defp parse_soap_request(body) do
    try do
      user_id =
        body
        |> xpath(~x"//GetUser/userId/text()"s)

      {:ok, %{"userId" => user_id}}
    rescue
      _ -> {:error, "Unable to parse SOAP request"}
    end
  end

  # Mock function to retrieve user data
  defp get_user(user_id) do
    %{id: user_id, name: "John Doe", email: "john.doe@example.com"}
  end

  # Helper function to build a SOAP-compliant response
  defp build_soap_response(user) do
    """
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
      <soapenv:Body>
        <GetUserResponse>
          <id>#{user.id}</id>
          <name>#{user.name}</name>
          <email>#{user.email}</email>
        </GetUserResponse>
      </soapenv:Body>
    </soapenv:Envelope>
    """
  end
end
