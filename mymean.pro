;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��[~_~];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��������
; MyMean
;
; Ŀ�ģ�
; �Զ�ά��������Ӽ�����ƽ��ֵ�ļ��㣬��0Ԫ�ز��������㡣
; �磺
; data = [[1,2,1], [1,2,0], [1,0,0], [0,0,0]]
; ��һ�У�(1+2+1)/3, �ڶ��У�(1+2)/2, �����У�(1)/1, �����У�0
; 
; ���������
; dataΪһ����ά����
;
; ����ֵ��
; data���Ӽ���ƽ��ֵ
;
; ��ע��
;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��\~_~\;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function MyMean, data
;data��һ�����Ӽ����ж��ٸ�Ԫ��
  dimensions = size(data, /DIMENSIONS)
; �����ķ���ֵ 
  r_data=fltarr(dimensions[1])
  for i=0l, dimensions[1]-1 do begin
    subscript = where(data[*, i] eq 0, count)
    if count eq dimensions[0] then begin
      r_data[i] = 0
    endif else begin
      r_data[i] = total(data[*, i])/(dimensions[0]-count)
    endelse
  endfor
  ;r_data = TRANSPOSE(r_data)
  return, r_data
End

