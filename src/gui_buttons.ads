package Gui_Buttons is
   --  Local workaround for df_imgui 0.1.0's Vec2 argument convention.
   function Button (Label : String) return Boolean;
end Gui_Buttons;
