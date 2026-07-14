{
  beetroot = {
    name = "beetroot";
    tags = [
      "all"
      "tailscale"
      "wifi"
    ];
    deploy.targetHost = "root@beetroot";
  };

  daikon = {
    name = "daikon";
    tags = [
      "all"
      "tailscale"
    ];
    deploy.targetHost = "root@daikon";
  };
}
