with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO;
with Adagb_Config;
with Gui_Buttons;
with Imgui;
with Imgui.Types;
with Imgui.Widgets;
with Imgui.Windows;
with Interfaces.C;
with Interfaces.C.Strings;
with SDL_Imgui_Bridge;

procedure Adagb is
   use type Interfaces.C.int;
   use type Imgui.Types.Window_Flags;

   Context : Imgui.Context := Imgui.Null_Context;
   Running : Boolean := True;
   Frames : Natural := 0;
   Frame_Limit : Natural := 0;

   procedure Cleanup is
   begin
      if not Imgui.Is_Null (Context) then
         SDL_Imgui_Bridge.Shutdown;
         Imgui.Destroy_Context (Context);
         Context := Imgui.Null_Context;
      end if;
   end Cleanup;

   procedure Fail (Operation : String) is
   begin
      raise Program_Error with Operation & ": " &
        Interfaces.C.Strings.Value (SDL_Imgui_Bridge.Error);
   end Fail;

   procedure Usage is
   begin
      Ada.Text_IO.Put_Line ("Usage: adagb [--help | --version | --frames N]");
      Ada.Text_IO.Put_Line ("  --frames N  Exit after N frames (N > 0).");
   end Usage;
begin
   if Ada.Command_Line.Argument_Count = 1 and then
     (Ada.Command_Line.Argument (1) = "--help" or else
      Ada.Command_Line.Argument (1) = "-h")
   then
      Usage;
      return;
   elsif Ada.Command_Line.Argument_Count = 1 and then
     (Ada.Command_Line.Argument (1) = "--version" or else
      Ada.Command_Line.Argument (1) = "-v")
   then
      Ada.Text_IO.Put_Line ("AdaGB " & Adagb_Config.Crate_Version);
      return;
   elsif Ada.Command_Line.Argument_Count = 2 and then
     Ada.Command_Line.Argument (1) = "--frames"
   then
      Frame_Limit := Positive'Value (Ada.Command_Line.Argument (2));
      if Frame_Limit = 0 then
         raise Constraint_Error with "--frames must be greater than zero";
      end if;
   elsif Ada.Command_Line.Argument_Count /= 0 then
      Usage;
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   Context := Imgui.Create_Context;
   if Imgui.Is_Null (Context) then
      raise Program_Error with "ImGui context creation failed";
   end if;
   if SDL_Imgui_Bridge.Initialise = 0 then
      Fail ("SDL / ImGui initialisation");
   end if;

   while Running loop
      exit when SDL_Imgui_Bridge.Poll = 0;
      SDL_Imgui_Bridge.New_Frame;
      Imgui.New_Frame;
      if Imgui.Windows.Begin_Window
        ("AdaGB", Flags =>
           Imgui.Types.Window_Always_Auto_Resize or
           Imgui.Types.Window_No_Saved_Settings)
      then
         Imgui.Widgets.Text ("Game Boy Color emulator written in Ada");
         Imgui.Widgets.Text ("No ROM loaded.");
         if Gui_Buttons.Button ("Quit") then
            Running := False;
         end if;
      end if;
      Imgui.Windows.End_Window;
      Imgui.Render;
      if SDL_Imgui_Bridge.Present = 0 then
         Fail ("Rendering");
      end if;
      Frames := Frames + 1;
      exit when Frame_Limit > 0 and then Frames >= Frame_Limit;
      delay 0.001;
   end loop;
   Cleanup;
   Ada.Text_IO.Put_Line ("Rendered frames:" & Natural'Image (Frames));
exception
   when E : others =>
      Ada.Text_IO.Put_Line
        (Ada.Text_IO.Standard_Error, Ada.Exceptions.Exception_Information (E));
      Cleanup;
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Adagb;
