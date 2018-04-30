string      sBounce             =   "Bounce Stand" ;
string      sBLeft              =   "Bounce Left" ;
string      sBRight             =   "Bounce Right" ;
string      sBForw              =   "Bounce Forward" ;
integer     iRLVchan            =   -1812221819;
string      active_anim;

anim( string anim_new )
{
    if (anim == active_anim)
        return;
    llStopAnimation( active_anim );
    active_anim = anim_new;
    llStartAnimation( active_anim );
}

default
{
    state_entry()
    {
        llSetCameraEyeOffset(<-2.0, 0.0, 2.0> );
        llSetCameraAtOffset(<4.0, 0.0, 2.0> );
        llSitTarget(<0.15,0.0,0.01>, ZERO_ROTATION);
    }
    on_rez(integer num)
    {
        llRegionSayTo(
            llGetOwner(),
            iRLVchan,
            "capture," +
            (string)llGetOwner() + ","
            "@sit:" + (string)llGetKey() + "=force|"
            "@unsit=n"
        );
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key sitter = llAvatarOnSitTarget();
            if ( sitter )
            {
                active_anim = "sit";
                llRequestPermissions( sitter, PERMISSION_TRIGGER_ANIMATION );
            }
            else
            {
                if( llGetAgentSize(sitter) != ZERO_VECTOR )
                    llStopAnimation( active_anim );
            }
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if ( str == "Release" )
        {
            if ( llAvatarOnSitTarget() != llGetOwner() )
                return;
            llSay(0, "You are released." );
            llRegionSayTo( llGetOwner(), iRLVchan, "ClearRLV," + (string)llGetOwner() + ",!release" );
            llUnSit( llGetOwner() );
            return;
        }
        if (str == CONTROL_FWD)
            anim(sBForw);
        else
        if (str == CONTROL_BACK)
            anim(sBForw);
        else
        if (str == CONTROL_LEFT)
            anim(sBLeft);
        else
        if (str == CONTROL_RIGHT)
            anim(sBRight
        else
        if (str == "STAND")
            anim(sBounce);
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
            anim(sBounce);
    }    
}
