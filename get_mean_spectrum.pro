;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��[~_~];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��������
; Shift_Mean
; ���÷�ʽ��
; Shift_Mean(data, flag)
;
; Ŀ�ģ�
; ����ά�����е����Ӽ��Ȱ����ֵ/��Сֵλ�ý���ƥ�䡢ƽ�ƣ�Ȼ���ƽ�ƺ�����Ӽ���ƽ��ֵ
; ��: A=[1, 2, 3]
;       [3, 5, 2]
;       [2, 2, 4]
;       [1, 2, 4] 
; ���ֵλ��ƥ��󣨵�һ��Ϊ��׼�� �ڶ������ֵλ�����һ����ͬ��ƽ�ƣ� ����������ƽ��һ��Ԫ�أ�:
;     A=[1, 2, 2]�� ��ƽ��ֵ�� [1.67] 
;       [3, 5, 4]            [4.00]
;       [2, 2, 4]            [2.67]
;       [1  2, 0]            [1.00]
;     
; ���������
; data ��ά���飨һά����ֱ�ӷ��أ�
; flag ƥ�䷽ʽ��flag=0 ���ֵƥ�䣬 flag=1 ��Сֵƥ�䣩
;
; ����ֵ��
; data���Ӽ�ƥ��ƽ�ƺ��ƽ��ֵ
;
; ��ע��
;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��\~_~\;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function shift_mean, data, flag
;С�ڶ�άֱ�ӷ���

;��Ҫ�任!
;data = transpose(data, [2, 1])
  if size(data, /N_DIMENSIONS) lt 2 then begin
    return, data
  endif

;����data��άά�ȣ�dimensions[0]Ϊ������dimensions[1]Ϊ����
  dimensions = size(data, /dimensions)
;�洢data�и����Ӽ������ֵ��λ��
  max_pos = intarr(dimensions[0])
  min_pos = intarr(dimensions[0])
  for i=0l, dimensions[0]-1 do begin
    max_value = max(data[i, *], max_subscript, SUBSCRIPT_MIN=min_subscript)
    max_pos[i] = max_subscript
    min_pos[i] = min_subscript
  endfor

;ȷ��data�и����Ӽ���ƽ�ƾ���
  switch (flag) of
    0: begin
    
      distances = intarr(dimensions[0])
      for i=0l, dimensions[0]-1 do begin
        distances[i] = max_pos[i] - max_pos[0]
      endfor
      
      break
    end
    else: begin
      distances = intarr(dimensions[0])
      for i=0l, dimensions[0]-1 do begin
        distances[i] = min_pos[i] - min_pos[0]
      endfor
    end
  endswitch



;�Ը��н���ƽ��
  for i=0l, dimensions[0]-1 do begin
    data[i, *] = MyShift(data[i, *], distances[i])
  endfor
;��ƽ�ƺ�����Ӽ���ƽ��ֵ
  ;r_data = mean(data, dimension=1) 
  r_data = MyMean(data)
  return, r_data 
End

FUNCTION HYPER2D, M

  ;������άͼ�������ά
  COMPILE_OPT idl2
  dims = SIZE(M, /dimensions)
   
  IF SIZE(M, /n_dimensions) NE 3 AND SIZE(M, /n_dimensions) NE 2 THEN BEGIN
    mytemp = DIALOG_MESSAGE('Input image must be 3D')
  ENDIF ELSE IF  SIZE(M, /n_dimensions) EQ 2 THEN BEGIN
    nb = 1
  ENDIF ELSE BEGIN
    nb = dims[2]
  ENDELSE
  
  ;ת�þ���
  M_temp = M
  FOR i = 0, nb-1 DO BEGIN
    M_temp[*,*,i] = TRANSPOSE(M[*,*,i])
  ENDFOR
  RETURN, REFORM(TEMPORARY(M_temp), dims[0]*dims[1], nb)
  
END

FUNCTION HYPER3D, M, ns, nl, nb

  ;ns - ����        nl - ����         nb - ������
  ;�����άͼ�������ά
  COMPILE_OPT idl2
  IF SIZE(M, /n_dimensions) NE 2 AND nb NE 1 THEN BEGIN
    mytemp = DIALOG_MESSAGE('Input image must be 2D')
  ENDIF ELSE BEGIN
    M_temp = FLTARR(ns, nl, nb)
    FOR i = 0, nb-1 DO BEGIN
      M_temp[*,*,i] = TRANSPOSE(REFORM(TRANSPOSE(M[*,i]), nl, ns))
    ENDFOR
    RETURN, TEMPORARY(M_temp)
  ENDELSE
  
END

Pro get_mean_spectrum

  compile_opt idl2
  
  envi, /restore_base_save_files
  envi_batch_init
  
  input_filenames = ENVI_PICKFILE(TITLE='����������ʱ����������', /MULTIPLE_FILES)
  if n_elements(input_filenames) eq 0 then return  
  
  output_filename = envi_pickfile(title='����ļ���' ,/output)
  if (output_filename eq '') then return
  
  wbase = widget_auto_base(title='ѡ������ƥ�䷽ʽ')
    wtoggle = widget_toggle(wbase, list=['���ֵƥ��', '��Сֵƥ��'], $
    uvalue='mtoggle', /auto)
  wresult = auto_wid_mng(wbase)
  if (wresult.accept eq 0) then return
  ;0Ϊ���ֵƥ��, 1Ϊ��Сֵƥ��
  pipei_flag = wresult.mtoggle
  
  ;�������ļ�
  input_file_count = n_elements(input_filenames)
  input_fileids = intarr(input_file_count)
  for i=0l, input_file_count-1 do begin
    envi_open_file, input_filenames[i], r_fid=r_fid
    if r_fid eq -1 then return
    input_fileids[i] = r_fid
  endfor
  
  
  envi_file_query, input_fileids[0], dims=dims, $
  ns=ns, $
  nl=nl, $
  nb=nb, $
  data_type=data_type, $
  interleave=interleave
  
  ;������ļ�
  openw, output_file_unit, output_filename, /get_lun
  
  ;�ֿ鴦������
  tile_nums = 10
  tile_lines = [nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl-nl/tile_nums*9]
  
  ;ѭ������Tiles������
  for i=0l, tile_nums-1 do begin
    
    input_data = make_array(ns, tile_lines[i], $
    nb, input_file_count, type=data_type)
    
    for j=0l, input_file_count-1 do begin
      for k=0l, nb-1 do begin
        input_data[*, *, k, j] = envi_get_data(fid=input_fileids[j], $
        dims=[dims[0], $
              dims[1], $
              dims[2], $
              i*nl/tile_nums, $
              i*nl/tile_nums+tile_lines[i]-1], $
              pos=k)
      endfor
    endfor
    
    ;�������3ά������ת��Ϊ2άfloat������
    input_data2d = make_array(ns*tile_lines[i], nb, input_file_count)
    for l=0, input_file_count-1 do begin
      input_data2d[*, *, l] = HYPER2D(input_data[*, *, *, l])
    endfor
    
    ;�������2ά����
    output_data = make_array(ns*tile_lines[i], nb)
    
    ;��ʼ����ƽ������
    for m=0l, ns*tile_lines[i]-1 do begin
      output_data[m, *] = shift_mean(input_data2d[m, *, *], pipei_flag)
    endfor
    
    output_data = HYPER3D(output_data, ns, tile_lines[i], nb)
    
    ;�����ݴ洢��ʽת��ΪBIL����д������ļ���
    output_data = transpose(temporary(output_data), [0, 2, 1])
    writeu, output_file_unit, output_data 
  
    print, '��', i, '��'
    
  endfor   
  
  ;�ر��ļ�  
  free_lun, output_file_unit
  
  map_info = envi_get_map_info(fid=input_fileids[0])
  envi_setup_head, fname=output_filename, ns=ns, nl=nl, nb=nb, map_info=map_info, $ 
  data_type=4, offset=0, interleave=1, $
  descrip='Test routine output', /write, /open
  
  envi_batch_exit

End