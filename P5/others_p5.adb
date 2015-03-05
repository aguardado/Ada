-- Alba Guardado Garcia

with Ada.Text_IO;
with Ada.Calendar;
with Lower_Layer_UDP; 
with Seq_N_T;
with Calendar_Image;
with Ada.Strings.Unbounded;
with Image_EP;


package body others_p5 is

	use type Seq.Seq_N_T;
	use type ASU.Unbounded_String;
	
	
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
				Comparacion:= True;
		elsif Image_EP.Image(K1.EP) = Image_EP.Image(K2.EP) then
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
				Comparacion:= True;
		elsif Image_EP.Image(K1.EP) = Image_EP.Image(K2.EP) then
			if K1.NSeq < K2.NSeq then
				Comparacion:= True;
			end if;
		end if;
		
		return Comparacion;
	end "<";


	function Mess_Id_T_To_String (K: Mess_Id_T) return String is --key to string
		Texto_Final: ASU.Unbounded_String;
		EP_I: ASU.Unbounded_String;
		NSeq_I: ASU.Unbounded_String;
	begin
		EP_I:= ASU.To_Unbounded_String(Image_EP.Image(K.EP));
		NSeq_I:= ASU.To_Unbounded_String(Seq.Seq_N_T'Image(K.NSeq));
		
		Texto_Final:= "[" & EP_I & "/" & Nseq_I & "]";
		return ASU.To_String(Texto_Final);
	end Mess_Id_T_To_String;
	
	
	function Destinations_T_To_String (D: Destinations_T) return String is --value to string
		Texto_Final: ASU.Unbounded_String;
		EP_I: ASU.Unbounded_String;
		Retries_I: ASU.Unbounded_String;
	begin
		Texto_Final := ASU.To_Unbounded_String("[");
		for i in 1..10 loop
			EP_I:= ASU.To_Unbounded_String(Image_EP.Image(D(i).EP));
			Retries_I:= ASU.To_Unbounded_String(Natural'Image(D(i).Retries));
			
			if(ASU.To_String(EP_I)) /= "null" then
				Texto_Final:= Texto_Final & ASCII.LF & EP_I & " || Retries: " & Retries_I;
			end if;
		end loop;
		
		Texto_Final := Texto_Final & "]";
		return ASU.To_String(Texto_Final);
	end Destinations_T_To_String;
	

	function Value_T_to_String (K: Value_T) return String is 
		Texto_Final: ASU.Unbounded_String;
		EP_I: ASU.Unbounded_String;
		NSeq_I: ASU.Unbounded_String;
	begin
		EP_I:= ASU.To_Unbounded_String(Image_EP.Image(K.EP_H_Creat));
		NSeq_I:= ASU.To_Unbounded_String(Seq.Seq_N_T'Image(K.Seq_N));
		
		Texto_Final:= "[" & EP_I & "/" & Nseq_I & "]";
		return ASU.To_String(Texto_Final);
	end Value_T_To_String;

	
end Others_P5;	
