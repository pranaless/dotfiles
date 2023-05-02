{ lib, ... }:

with lib;
rec {
  parseColor = x:
    let
      pipeNullable = fs: flip pipe (map mapNullable fs);
      hexToAttrs = v:
        let alpha = let a = elemAt v 3; in if a == "" then "ff" else a;
        in builtins.fromTOML ''
          red=0x${elemAt v 0}
          green=0x${elemAt v 1}
          blue=0x${elemAt v 2}
          alpha=0x${alpha}
        '';
      formats = [
        (pipeNullable [
          (builtins.match "#([0-9a-fA-F]{2}{3,4})")
          (flip elemAt 0)
          (v: genList (i: builtins.substring (2*i) 2 v) 4)
          hexToAttrs
        ])
        (pipeNullable [
          (builtins.match "#([0-9a-fA-F]{3,4})")
          (flip elemAt 0)
          (v: genList (i: builtins.substring i 1 v) 4)
          (v: map (x: x + x) v)
          hexToAttrs
        ])
        (pipeNullable [
          (builtins.match "rgba?[[:space:]]*\\([[:space:]]*(.*)\\)")
          (flip elemAt 0)
          (let
            matchToAttrs = v: { value = builtins.fromJSON (elemAt v 0); rest = elemAt v 2; };
            once = x: mapNullable matchToAttrs
              (builtins.match ",[[:space:]]*([0-9]+(\\.[0-9]+)?)[[:space:]]*(.*)" x);
            repeat = r:
              let x = once r;
              in if x != null then [ x.value ] ++ (repeat x.rest) else [ ];
          in v: repeat ",${v}")
          (v: if length v < 3 || length v > 4
            then null
            else {
              red   = elemAt v 0;
              green = elemAt v 1;
              blue  = elemAt v 2;
              alpha = if length v == 4 then elemAt v 3 * 255.0 else 255;
            })
          (mapAttrs (_: v: if v > 255 then 255 else v))
          (mapAttrs (_: v: builtins.fromJSON (head (splitString "." (toString v)))))
        ])
      ];
    in findSingle (v: v != null) null null (map (f: f x) formats);

  formatAsHex = useAlpha: c:
    let
      color = if isString c then parseColor c else c;
      digit = d: fixedWidthString 2 "0" (toHexString d);
    in "${digit color.red}${digit color.green}${digit color.blue}${optionalString useAlpha (digit color.alpha)}";
}
