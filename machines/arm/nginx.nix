{ ... }: {
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
  };
  services.nginx.virtualHosts."ocp.luksab.de" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/overviewer";
  };
  services.nginx.virtualHosts."luksab.de" = {
    addSSL = true;
    enableACME = true;
    root = "/var/www/luksab.de";
    locations = { "/" = { extraConfig = "access_log off;"; }; };
  };
  services.nginx.virtualHosts."private.luksab.de" = {
    addSSL = true;
    enableACME = true;
    root = "/var/www/private";
    locations = {
      "/" = {
        extraConfig = ''
          allow 176.198.43.0;
          allow 91.65.89.69;
          deny all;'';
      };
    };
  };
  security.acme.acceptTerms = true;
  security.acme.certs = {
    "ocp.luksab.de".email = "lukassabatschus@gmail.com";
    "luksab.de".email = "lukassabatschus@gmail.com";
    "private.luksab.de".email = "lukassabatschus@gmail.com";
  };
}