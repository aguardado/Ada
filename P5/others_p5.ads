-- Alba Guardado Garcia

with Ada.Text_IO;
with Ada.Calendar;
with Lower_Layer_UDP; 
with Seq_N_T;
with Calendar_Image;
with Ada.Strings.Unbounded;
with Image_EP;
with Ada.Command_Line;
with Chat_Messages;

package others_p5 is

	package LLU renames Lower_Layer_UDP;
	package Seq renames Seq_N_T;
	package C_Image renames Calendar_Image;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	
	-- Sender_Dests
	type Mess_Id_T is record 
		EP: LLU.End_Point_Type;
		NSeq: Seq.Seq_N_T;
	end record;
	
	type Destination_T is record
		EP: LLU.End_Point_Type:= null;
		Retries: Natural:= 0; -- Maximo 10
	end record;
	
	type Destinations_T is array (1..10) of Destination_T;
	
	-- Sender_Buffering
	type Value_T is record
		EP_H_Creat: LLU.End_Point_Type;
		Seq_N: Seq.Seq_N_T;
		P_Buffer: CM.Buffer_A_T;
	end record;
	
	
	-- Declaracion de funciones
	function "=" (K1: Mess_Id_T; K2: Mess_Id_T) return Boolean ;
	
	
	function ">" (K1: Mess_Id_T; K2: Mess_Id_T) return Boolean;
	
	
	function "<" (K1: Mess_Id_T; K2: Mess_Id_T) return Boolean;

	function Mess_Id_T_To_String (K: Mess_Id_T) return String;

	
	function Destinations_T_To_String (D: Destinations_T) return String ;
	

	function Value_T_to_String (K: Value_T) return String;

	
end Others_P5;	
