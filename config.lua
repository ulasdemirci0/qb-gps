Config = {
    UpdateTick = 500,    --msec (Blip update süresi) / (Blip Update Interval)
    ShowYourself = true, -- (Kişinin haritada kendini görüp göremeyeceğini seçin) / (You can see your own blip if true)
    VehicleBlips = true, -- (Araçtayken blip işaretinin değişmesi ayarı) / (Blip sprite changes in vehicle if true)
    Jobs = {
        ["ems"] = {
            sprite = 1,
            color = 1,
        },
        ["mrpd"] = {
            sprite = 1,
            color = 84,
        }
    },
    Locales = {
        ["unknown"] = "Bilinmiyor",
        ["gps_closed"] = "GPS Sistemi Devredışı",
        ["gps_opened"] = "GPS Sistemi Aktif!"
    }
}
