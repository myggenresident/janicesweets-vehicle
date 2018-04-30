string      sRBounce            =   "Rider Sit" ;
string      sRLeft              =   "Rider Left" ;
string      sRRight             =   "Rider Right" ;
string      sRForw              =   "Rider Forward" ;
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
        llSetCameraAtOffset( <4.0,  0.0, 2.0> );
        llSitTarget( <0,0,0.75>, ZERO_ROTATION);
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
            inv_update();
        if (change & CHANGED_LINK) 
        {
            key sitter = llAvatarOnSitTarget();
            if ( sitter )
            {
                llRequestPermissions( sitter, PERMISSION_TRIGGER_ANIMATION|PERMISSION_TRACK_CAMERA );
                llRegionSayTo( llGetOwner(), iRLVchan, "AcceptPerms," + (string)sitter + ",@unsit=n" );
            }
            else
            {
                if(llGetAgentSize(sitter) != ZERO_VECTOR)
                {
                    // Still in the sim, so we try to free him/her
                    if ( active_anim )
                        llStopAnimation( active_anim );
                    llReleaseControls();
                }
            }            
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (msg == "Release")
        {
            llRegionSayTo( llGetOwner(), iRLVchan, "ClearRLV," + (string)llGetOwner() + ",!release");
            // is (s)he still sitting on us, then stand him/her up.
            if ( llAvatarOnSitTarget() == llGetOwner() )
                llUnSit( llGetOwner() );
            return;
        }
        if (str == CONTROL_FWD)
            // walking straight
            anim(sRForw);
        else
        if (str == CONTROL_BACK)
            // walking straight backwards
            // Same animation as forward - might look odd.
            anim(sRForw);
        else
        if (str == CONTROL_LEFT)
            // turning
            anim(sRLeft);
        else
        if (str == CONTROL_RIGHT)
            // turning
            anim(sRRight);
        else
        if (str == "STAND")
            // not moving
            anim(sRBounce);
        else
        if (str == "ON")
            // ignore ON
            return;
        else
        if (str == "OFF")
            // ignore OFF
            return;
                                                      
    }
    on_rez(integer iNum)
    {
        active_anim = "";
    }
    run_time_permissions(integer perm)
    {
        animateperms();
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(
                CONTROL_FWD         |
                CONTROL_BACK        |
                CONTROL_ROT_LEFT    |
                CONTROL_ROT_RIGHT   |
                CONTROL_UP          |
                CONTROL_DOWN        |
                CONTROL_LEFT        |
                CONTROL_RIGHT,
                TRUE,
                TRUE
            );
        }
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            llStopAnimation("sit");
            // Default animation
            llStartAnimation(sRBounce);
        }
    }
}
