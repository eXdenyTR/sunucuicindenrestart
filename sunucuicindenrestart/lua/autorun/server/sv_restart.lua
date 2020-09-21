sv_restart = sv_restart or {}
util.AddNetworkString( "sv_restart" )
if not game.IsDedicated() then return end



local function DoRestart()
	if not system.IsWindows() then
		local ShutDown=GAMEMODE.ShutDown
		function GAMEMODE:ShutDown()
			ShutDown( self )
			game.ConsoleCommand( "escape\n" ) 
			
		end
		game.ConsoleCommand( "disconnect\n" )
	else
		game.ConsoleCommand( "_restart\n" )
	end
end
local function DoRetry()
	
		for _,ply in ipairs( player.GetAll() ) do
			ply:ConCommand( "retry" )
		end

end

local function callback( ply, cmd, args )
	if not IsValid( ply ) or ply:IsSuperAdmin() then
		local delay = tonumber( args[1] ) or 10
		if delay==0 then 
			timer.Create( "sv_restart", 0.2, 1, DoRestart )
			DoRetry()
		elseif delay>0 then
			timer.Create( "sv_restart", delay, 1, DoRestart )
			PrintMessage( HUD_PRINTCENTER, ""..delay.." saniye içinde sunucu yeniden başlatılacak!" )
			sv_restart.RestartTime = RealTime()+delay
			timer.Create( "sv_restart_retry", delay-0.2, 1, DoRetry )
			net.Start( "sv_restart" )
				net.WriteFloat( delay )
			net.Broadcast()
			if delay>10 then
				timer.Create( "sv_restart_LastWarning", delay-5, 1, function()
					PrintMessage( HUD_PRINTCENTER, "5 saniye içinde sunucu yeniden başlatılacak!" )
				end )
			end
		else
			sv_restart.RestartTime = nil
			timer.Remove( "sv_restart" )
			timer.Remove( "sv_restart_retry" )
			PrintMessage( HUD_PRINTCENTER, "Yeniden başlatma iptal edildi!" )
			net.Start( "sv_restart" )
				net.WriteFloat( -1 )
			net.Broadcast()
			timer.Remove( "sv_restart_LastWarning" )
		end
	end
end

concommand.Add( "sv_restart", callback, nil, "sv_restart [Gecikme=10]\n   Sunucuyu {delay} saniye içinde yeniden başlatın\n   Yeniden başlatmayı iptal etmek için şunu yazın: sv_restart -1", FCVAR_SERVER_CAN_EXECUTE )

net.Receive( "sv_restart", function( len, ply )
	callback( ply, nil, {net.ReadFloat()} )
end )

hook.Add( "CheckPassword", "sv_restart", function()
	if sv_restart.RestartTime then
		return false, string.format( "Sunucu %i saniye içinde yeniden başlayacak!\nLütfen tekrar açılmadan önce bekleyin.", math.ceil( sv_restart.RestartTime-RealTime() ) )
	end
end )
