-------------------------------------------------------------------------------
--  Copyright (c) 2016 Daniel King
--
--  Permission is hereby granted, free of charge, to any person obtaining a
--  copy of this software and associated documentation files (the "Software"),
--  to deal in the Software without restriction, including without limitation
--  the rights to use, copy, modify, merge, publish, distribute, sublicense,
--  and/or sell copies of the Software, and to permit persons to whom the
--  Software is furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--  DEALINGS IN THE SOFTWARE.
-------------------------------------------------------------------------------

package body DW1000.System_Time
with SPARK_Mode => On
is

   function System_Time_Offset (Time : in Fine_System_Time;
                                Span : in System_Time_Span) return Fine_System_Time
   is
      Span_FST : constant Fine_System_Time := Fine_System_Time (Span);
   begin
      if Fine_System_Time'Last - Time >= Span_FST then
         return Time + Span_FST;
      else
         --  Wrap-around case
         return Fine_System_Time'Last - Span_FST;
      end if;
   end System_Time_Offset;


   function To_Fine_System_Time (Bits : in Bits_40) return Fine_System_Time
     with SPARK_Mode => Off
   --  SPARK mode is disabled as a workaround because GNATprove does not
   --  support an operation mixing two different fixed-point types.
   is
      type Fixed_40 is delta 1.0 range 0.0 .. 2.0**40 - 1.0
        with Size => 40,
        Small => 1.0;
      --  Type big enough to hold all possible values of Bits_40.
      --
      --  Normally, values of Bits_40 cannot be multiplied with fixed point types,
      --  however, casting a Bits_40 value to Fixed_40 then permits such an
      --  operation between Fixed_40 and the other fixed point type
      --  (e.g. System_Time).

   begin
      return Fine_System_Time (Fixed_40 (Bits) * Fine_System_Time'Delta);
   end To_Fine_System_Time;


   function To_Coarse_System_Time (Bits : in Bits_40) return Coarse_System_Time
     with SPARK_Mode => Off
   --  SPARK mode is disabled as a workaround because GNATprove does not
   --  support an operation mixing two different fixed-point types.
   is
      type Fixed_31 is delta 1.0 range 0.0 .. 2.0**31 - 1.0
        with Size => 31,
        Small => 1.0;

      MSB : constant Bits_31 := Bits_31 (Bits / 2**9);
      --  The DW1000 ignores the 9 low order bits of the timestamp; they are
      --  set to 0.

   begin
      return Coarse_System_Time (Fixed_31 (MSB) * Coarse_System_Time'Delta);
   end To_Coarse_System_Time;

end DW1000.System_Time;
