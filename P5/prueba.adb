-- Alba Guardado Garcia

with Ada.Text_IO;
with Ada.Calendar;
with Lower_Layer_UDP; 
with Seq_N_T;
with Calendar_Image;
with Ada.Strings.Unbounded;
with Image_EP;
with Ada.Command_Line;
with Handler;
--with Others_P5;

procedure prueba is

	package LLU renames Lower_Layer_UDP;
	package Seq renames Seq_N_T;
	package C_Image renames Calendar_Image;
	package ASU renames Ada.Strings.Unbounded;
		--package Othrs renames Others_P5;
	

	use type Seq.Seq_N_T;
	use type ASU.Unbounded_String;
	
	type Array_Key is array (1..10) of LLU.End_Point_Type;
	
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
	type Buffer_A_T is access LLU.Buffer_Type;

	type Value_T is record
		EP_H_Creat: LLU.End_Point_Type;
		Seq_N: Seq.Seq_N_T;
		P_Buffer: Buffer_A_T;
	end record;
	
	
	--procedure Inserto_EP_Value_SD (	Array_EP: in out Handler.Neighbor.Keys_Array_Type; Longitud_Lista: in out Natural; 
	--											Value_Sender_Dests: in out Othrs.Destinations_T) is --Despues de un put_neighs
	--begin
	--	Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
	--	Ada.Text_IO.Put_Line("ARRAY_EP");
	--	for k in 1..10 loop
	--		Ada.Text_IO.Put_Line((Image_EP.Image(Array_EP(k))));
	--	end loop;
	--	Ada.Text_IO.New_Line;
	--	Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
	--	--for k in 1..Value_Sender_Dests'Range loop
	--	for k in 1..10 loop --1..10
	--		if Longitud_Lista <= k then
	--			--if Image_EP.Image(Array_EP(k)) /= "null" then
	--			if Array_EP(k) /= null then
	--				Value_Sender_Dests(k).EP:= Array_EP(k);
	--			end if;
	--		else
	--			Value_Sender_Dests(k).EP:= null;
	--		end if;
	--		
	--		Ada.Text_IO.Put_Line((Image_EP.Image(Value_Sender_Dests(k).EP)));
	--	end loop;
	--end Inserto_EP_Value_SD;
	
	function "=" (K1: Mess_Id_T; K2: Mess_Id_T) return Boolean is
		Iguales: Boolean:= False;
	begin
		if Image_EP.Image(K1.EP) = Image_EP.Image(K2.EP) then
			if K1.NSeq = K2.NSeq then
				Iguales:= True;
			end if;
		end if;
		
		return Iguales;
	end "=";
	
	
	function ">" (K1: Mess_Id_T; K2: Mess_Id_T) return Boolean is
		Comparacion: Boolean:= False;
	begin
		if Image_EP.Image(K1.EP) > Image_EP.Image(K2.EP) then
			if K1.NSeq > K2.NSeq then
				Comparacion:= True;
			end if;
		end if;
		
		return Comparacion;
	end ">";
	
	
	function "<" (K1: Mess_Id_T; K2: Mess_Id_T) return Boolean is
		Comparacion: Boolean:= False;
	begin
		if Image_EP.Image(K1.EP) < Image_EP.Image(K2.EP) then
			if K1.NSeq < K2.NSeq then
				Comparacion:= True;
			end if;
		end if;
		
		return Comparacion;
	end "<";


	
	function Destinations_T_To_String (D: Destinations_T) return String is --value to string
		Texto_Final: ASU.Unbounded_String;
		EP_I: ASU.Unbounded_String;
		Retries_I: ASU.Unbounded_String;
	begin
		Texto_Final := ASU.To_Unbounded_String("[");
		for i in 1..10 loop
			--Ada.TExt_IO.Put_Line("HOLA");
			EP_I:= ASU.To_Unbounded_String(Image_EP.Image(D(i).EP));
			--EP_I:= ASU.To_Unbounded_String(LLU.Image(D(i).EP));
			Retries_I:= ASU.To_Unbounded_String(Natural'Image(D(i).Retries));
			if(ASU.To_String(EP_I)) /= "null" then
				Texto_Final:= Texto_Final & ASCII.LF & EP_I & " || Retries: " & Retries_I;
			end if;
		end loop;
		
		Texto_Final := Texto_Final & "]";
		return ASU.To_String(Texto_Final);
	end Destinations_T_To_String;
	
	
D: Destinations_T;
Texto: ASU.Unbounded_String;

Key_Sender_Dests: Mess_Id_T;
Key_Sender_Dests2: Mess_Id_T;

Value_Sender_Dests: Destinations_T;
EP1: LLU.End_Point_Type;
Success: Boolean:= True;
EP2: LLU.End_Point_Type;
Array_EP: Array_Key;
Longitud_Lista: Integer;
Image:ASU.Unbounded_String;
EP3: LLU.End_Point_Type;
begin

EP1:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(1)), 9001);
EP2:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(2)), 9002);
EP3:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(3)), 9003);


	Key_Sender_Dests.EP:= EP1;
	Key_Sender_Dests.NSeq:= 1;
	
	Key_Sender_Dests.EP:= EP1;
	Key_Sender_Dests.NSeq:= 2;
	
	Success:= "=" (Key_Sender_dests, Key_Sender_Dests2);
	if Success = True then
		Ada.Text_IO.Put_Line("TRUE =");
	else
		Ada.Text_IO.Put_Line("FALSE =");
	end if;
	
	Success:= "<" (Key_Sender_dests, Key_Sender_Dests2);
	if Success = True then
		Ada.Text_IO.Put_Line("TRUE <");
	else
		Ada.Text_IO.Put_Line("FALSE <");
	end if;
	
	Success:= ">" (Key_Sender_dests, Key_Sender_Dests2);
	if Success = True then
		Ada.Text_IO.Put_Line("TRUE >");
	else
		Ada.Text_IO.Put_Line("FALSE >");
	end if;
	
	
Array_EP(1):= EP1;
Array_EP(2):= EP2;
Array_EP(3):= EP3;
Longitud_Lista:=2;

	for k in 1..10 loop --1..10
		if Longitud_Lista <= k then
			Image:= ASU.To_Unbounded_String(Image_EP.Image(Array_EP(k)));
			if Image /= "null" then
				Value_Sender_Dests(k).EP:= Array_EP(k);
			end if;
		else
			Value_Sender_Dests(k).EP:= null;
		end if;
	end loop;
	


	
	D(1).EP:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(1)), 9001);
	D(2).EP:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(2)), 9002);
	D(3).EP:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(3)), 9003);
	
	--D(1).Retries:= 2;
	--D(2).Retries:= 3;
	--D(3).Retries:= 4;
	
	Texto:= ASU.To_Unbounded_String(Destinations_T_To_String (D));
	Ada.Text_IO.Put_Line("PRUEBA VALUE_TO_STRING");
	Ada.Text_IO.Put_Line(ASU.To_String(Texto));
	
	
end;
