;������ֱ�ߵĽ���
;
; ����
; P1:ֱ��1���������--- P2:ֱ��1���յ�����
; P1S:ֱ��2���������--- P2S:ֱ��2���յ�����
; �ཻ�򷵻ؽ��㣬���ཻ�򷵻�-1
;Example:
;   ֱ��: [-1,-1],[1,1]
;   ֱ�ߣ�[1,0],[0,1]
;   point = Cal2linesintersectpoint([-1,-1],[1,1],[1,0],[0,1])

FUNCTION CAL2LINESINTERSECTPOINT, P1,P2,P1S,P2S
  ;
  COMPILE_OPT IDL2
  ;�����1���غ���
  IF ARRAY_EQUAL(P1, P2) THEN BEGIN
    IF ARRAY_EQUAL(P1S, P2S ) THEN BEGIN
      IF P1 EQ P2 THEN RETURN,P1
      RETURN, -1
    ENDIF ELSE BEGIN
      IF CALDISTANCEPTOLINE(P1,P1S,P2S) EQ 0 THEN RETURN, P1
      RETURN,-1
    ENDELSE
  ;��1�ĵ㲻�غ�
  ENDIF ELSE BEGIN
    IF ARRAY_EQUAL(P1S ,P2S) THEN BEGIN
      RETURN, P1S
    ENDIF ELSE BEGIN
      ;�����һ��ֱ�ߴ�ֱx��
      IF (P1[0]-P2[0]) EQ 0 THEN BEGIN
        ipX = p1[0];
        ;�ڶ���Ҳ��ֱ
        IF (P1S[0]-P2S[0]) EQ 0 THEN BEGIN
          ;���ཻ
          RETURN, -1
        ENDIF ELSE BEGIN
          ;
          k2 = FLOAT(P1S[1]-P2S[1])/(P1S[0]-P2S[0])
          b2 = FLOAT(P1S[0]*P2S[1]-P2S[0]*P1S[1])/(P1S[0]-P2S[0])
          ;
          ipY = k2*ipX+b2
          RETURN,[ipX,ipY]
        ENDELSE
      ;�ڶ���ֱ�ߴ�ֱX��
      ENDIF ELSE IF (P1S[0]-P2S[0]) EQ 0 THEN BEGIN
        ipX = p2s[0];
        k1 = FLOAT(P1[1]-P2[1])/(P1[0]-P2[0])
        b1 = FLOAT(P1[0]*P2[1]-P2[0]*P1[1])/(P1[0]-P2[0])
        ipY = k1*ipX+b1
        RETURN,[ipX,ipY]

      ;������ֱ
      ENDIF ELSE BEGIN
        k1 = FLOAT(P1[1]-P2[1])/(P1[0]-P2[0])
        b1 = FLOAT(P1[0]*P2[1]-P2[0]*P1[1])/(P1[0]-P2[0])
        ;
        k2 = FLOAT(P1S[1]-P2S[1])/(P1S[0]-P2S[0])
        b2 = FLOAT(P1S[0]*P2S[1]-P2S[0]*P1S[1])/(P1S[0]-P2S[0])
        ;�������ֱY��
        IF (K2 EQ 0) AND(K1 EQ 0) THEN RETURN,-1
        ipX = (b2-b1)/(k1-k2)
        ipY = (k1*b2-k2*b1)/(k1-k2)
        output = make_array(2, type=5)
        output[0] = ipX
        output[1] = ipY
        RETURN,output
      ENDELSE
    ENDELSE
  ENDELSE
;
END

;��ȡS��L
;input_dataΪ�������ݣ� hΪˮƽ��
;���磺
;input_data = [[x1, y1], [x2, y2], [x3, y3]...]
;h = ����
Function get_S_and_L, input_data, h

  compile_opt idl2
  
  output_data = make_array(2, value=0, type=4)
  
  d = size(input_data, /n_dimensions)
  if (d ne 2) then begin
    print, 'd is not 2 dimensions!'
    return, -999999
  endif
  
  S=0
  L=0
  d_n = size(input_data, /dimensions)
  for i=0, d_n[1]-2 do begin
    
    ;
    Pa_x = input_data[0, i]
    Pa_y = input_data[1, i]
    Pb_x = input_data[0, i+1]
    Pb_y = input_data[1, i+1]
    
    ;�ж���μ���S,L
    if ((min([Pa_y, Pb_y]) ge h) && (Pa_y ne Pb_y)) then begin
    ;S and L eq 0, ���㶼��h�Ϸ�����h���غ�
      dS = 0
      dL = 0
    endif else if (Pa_y-h)*(Pb_y-h) ge 0 then begin
    ;�޽���,���·�
      ds = (abs(Pa_y - h) + abs(Pb_y - h)) * (abs(Pb_x - Pa_x)) / 2
      dl = sqrt((Pa_y-Pb_y)^2 + (Pa_x-Pb_x)^2) 
    endif else begin
      ;�н������, ���㽻��P_c
      P1_s = [Pa_x, Pa_y]
      P1_e = [Pb_x, Pb_y]
      P2_s = [-1.0, h]
      P2_e = [1000.0, h]
      Pc = cal2linesintersectpoint(P1_s, P1_e, P2_s, P2_e)
      
      print, Pc
      
      ;����ϵ͵�Pm
      Pa = [Pa_x, Pa_y]
      Pb = [Pb_x, Pb_y]
      Pm = (min([Pa_y, Pb_y]) eq Pa_y) ? Pa : Pb
      
      ;����S��L
      ds = abs(h-Pm[1])*abs(Pc[0]-Pm[0])/2
      dl = sqrt((Pc[0]-Pm[0])^2 + (Pc[1]-Pm[1])^2) 
    endelse
    
    S = S + ds
    L = L + dl  
  endfor
  
  output_data[0] = S
  output_data[1] = L
  
  return, output_data

End

Pro cal_S_and_L

  compile_opt idl2
  
  input_filename = dialog_pickfile(title='ѡ����������', /read)
  if (input_filename eq '') then return
  
  ;����h
;  base = WIDGET_BASE()
;  field = CW_FIELD(base, TITLE = "Name", /FRAME)
;  WIDGET_CONTROL, base, /REALIZE
  
  
  ;��ȡCSV�ļ��е����ݸ�data�ṹ��
  data=READ_CSV(input_filename)
  
  input_data = make_array(2, n_elements(data.field1), type=4)
  input_data[0, *] = data.field1
  input_data[1, *] = data.field2
  print, size(input_data, /dimensions)
  
  print, get_s_and_l(input_data, 1448.022)
  

End