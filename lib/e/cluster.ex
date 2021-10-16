defmodule E.Cluster do
  @moduledoc false

  @spec poll_ec2(String.t(), [String.t()]) :: [ip_address :: String.t()]
  def poll_ec2(name, regions \\ ["eu-north-1", "ap-southeast-1"]) do
    import SweetXml, only: [sigil_x: 2]

    # maybe use vpc-id per region as well?
    params = [filters: [{"tag:Name", name}, {"instance-state-name", "running"}]]
    request = ExAws.EC2.describe_instances(params)

    regions
    |> Enum.map(fn region ->
      {:ok, %{body: body}} = ExAws.request(request, region: region)

      body
      |> SweetXml.xpath(private_ip_address_xpath())
      |> Enum.uniq()
    end)
    |> List.flatten()
  end

  defp private_ip_address_xpath do
    import SweetXml, only: [sigil_x: 2]

    ~x"//DescribeInstancesResponse/reservationSet/item/instancesSet/item/privateIpAddress/text()"ls
  end
end
