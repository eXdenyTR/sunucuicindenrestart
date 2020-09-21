sv_restart = sv_restart or {}

local function callback( ply, cmd, args )
	if IsValid( ply ) and ply:IsSuperAdmin() then
		net.Start( "sv_restart" )
			net.WriteFloat( tonumber( args[1] ) or 10 )
		net.SendToServer()
	else
		MsgN( "Sunucuyu yeniden başlatabilmek için üst yönetim ekibinde olmalısın!" )
	end
end

concommand.Add( "sv_restart", callback, nil, "sv_restart [Gecikme=10]\n   Sunucuyu {delay} saniye içinde yeniden başlatın\n   Yeniden başlatmayı iptal etmek için şunu yazın: sv_restart -1" )

net.Receive( "sv_restart", function()
	local delay = net.ReadFloat()
	if delay>0 then
		sv_restart.timeout = RealTime()+delay
	else
		sv_restart.timeout = nil
	end
end )

do
	surface.CreateFont( "sv_restart_title", {
		size=16,
		weight=750,
		antialias=false,
		additive=false,
		outline=true,
	} )
	surface.CreateFont( "sv_restart_time", {
		size=29,
		antialias=true,
		additive=false,
		outline=true,
	} )
	local hud_x = ScrW()*0.6667
	local title = "Sunucu yeniden başlatılıyor!"
	local title_w = 0
	local time = 0
	local time_w = 0
	local hud_w = 0
	local bg = Color( 0,0,0,128 )
	hook.Add( "HUDPaintBackground", "sv_restart", function()
		if sv_restart.timeout then
			hud_x = ScrW()*0.6667
			surface.SetFont( "sv_restart_title" )
			title_w = surface.GetTextSize( title )
			time = math.floor( sv_restart.timeout-RealTime() )
			surface.SetFont( "sv_restart_time" )
			time_w = surface.GetTextSize( time )
			hud_w = math.max( title_w+4, time_w+6 )
			draw.RoundedBoxEx( 0, hud_x,0, hud_w,50, bg )
		end
	end )
	hook.Add( "HUDPaint", "sv_restart", function()
		if sv_restart.timeout then
			surface.SetFont( "sv_restart_title" )
			surface.SetTextColor( 255,160,160 )
			surface.SetTextPos( hud_x+( ( hud_w-title_w )/2 ), 2 )
			surface.DrawText( title )
			surface.SetFont( "sv_restart_time" )
			surface.SetTextColor( 255,255,255 )
			surface.SetTextPos( hud_x+( ( hud_w-time_w )/2 ), 20 )
			surface.DrawText( time )
		end
	end )
end
