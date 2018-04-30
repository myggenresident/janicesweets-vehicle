string      sRBounce            =   "Rider Sit" ;
string      sRLeft              =   "Rider Left" ;
string      sRRight             =   "Rider Right" ;
string      sRForw              =   "Rider Forward" ;
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
                active_anim = "sit";
                llRequestPermissions( sitter, PERMISSION_TRIGGER_ANIMATION|PERMISSION_TRACK_CAMERA );
            }
            else
            {
                if(llGetAgentSize(sitter) != ZERO_VECTOR)
                {
                    // Still in the sim, so we try to free him/her
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
            // Ignore this for the driver's seat
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
            anim(sRBounce);
        }
    }
}
