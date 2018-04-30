string      sRBounce            =   "Rider Sit" ;
string      sRLeft              =   "Rider Left" ;
string      sRRight             =   "Rider Right" ;
string      sRForw              =   "Rider Forward" ;
string      active_anim;

anim( string anim_new )
{
    if ( llGetPermissions() & PERMISSION_TRIGGER_ANIMATION )
    {
        if (anim == active_anim)
            return;
        llStopAnimation( active_anim );
        active_anim = anim_new;
        llStartAnimation( active_anim );
    }
}

default
{
    state_entry()
    {
        llSetCameraEyeOffset(<-2.0, 0.0, 2.0> );
        llSetCameraAtOffset( <4.0,  0.0, 2.0> );
        llSitTarget( <0,0,0.75>, ZERO_ROTATION);
        active_anim = "";
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK) 
        {
            key sitter = llAvatarOnSitTarget();
            llMessageLinked( LINK_ROOT, 0, "Driver", sitter );
            if ( sitter )
            {
                active_anim = "sit";
                llRequestPermissions( sitter, PERMISSION_TRIGGER_ANIMATION|PERMISSION_TRACK_CAMERA );
            }
            else
            {
                if(llGetAgentSize(sitter) != ZERO_VECTOR)
                {
                    // Still in the sim, so we try to free him/her.
                    // If we have permission still.
                    if ( llGetPermissions & PERMISSION_TRIGGER_ANIMATION )
                        llStopAnimation( active_anim );
                }
            }            
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == (string)CONTROL_FWD)
            // walking straight
            anim(sRForw);
        else
        if (str == (string)CONTROL_BACK)
            // walking straight backwards
            // Same animation as forward - might look odd.
            anim(sRForw);
        else
        if (str == (string)CONTROL_LEFT)
            // turning
            anim(sRLeft);
        else
        if (str == (string)CONTROL_RIGHT)
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
        if (perm & PERMISSION_TRIGGER_ANIMATION)
            anim(sRBounce);
    }
}
