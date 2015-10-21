;sg_arguments is a array [nleft, nright, order, degree]
;data is a mutilbands image
Function Sg_filter, data, sg_arguments

  compile_opt idl2
  
  savgol_filter = savgol(sg_arguments[0], sg_arguments[1], sg_arguments[2], sg_arguments[3])
  
;  return, transpose(convol(transpose(temporary(data)), savgol_filter, /edge_truncate))
  return, transpose(convol(transpose(data), savgol_filter, /edge_truncate))
    
End

;ȡ��ֵ����,data1��data2Ϊ�����ನ��Ӱ����߷ֿ�����(BSQ��ʽ����ά����)
;flagsΪȡ��ֵ�Ĳ���λ��
Function Max_filter, data1, data2, flags
  
  compile_opt idl2
  
  ;dimension[����,����,������]
  dimension = size(data1, /dimension)
  
  out_data = make_array(dimension[0], dimension[1], dimension[2], type=size(data1, /type))
  
  for i=0, dimension[0]-1 do begin    
    for j=0, dimension[1]-1 do begin    
      for k=0, dimension[2]-1 do begin
      
        if (where(flags eq k, /null) eq !null) then begin
          ;print, k, 'ȡ��ֵ'
          out_data[i, j, k] = data1[i, j, k] > data2[i, j, k]        
        endif else begin
          ;print, k, 'ȡСֵ'
          out_data[i, j, k] = data1[i, j, k] < data2[i, j ,k]
        endelse
            
      endfor
    endfor
  endfor  
  
  return, out_data
  
End

;�����������ͷ���ռ���ֽ���
;1: Byte (8 bits) 
;2: Integer (16 bits) 
;3: Long integer (32 bits) 
;4: Floating-point (32 bits) 
;5: Double-precision floating-point (64 bits) 
;6: Complex (2x32 bits) 
;9: Double-precision complex (2x64 bits) 
;12: Unsigned integer (16 bits) 
;13: Unsigned long integer (32 bits) 
;14: Long 64-bit integer 
;15: Unsigned long 64-bit integer
Function data_type_to_byte, data_type
  
  compile_opt idl2
  
  switch (data_type) of
    1: begin
      return, 1
      break
    end
    2: begin
      return, 2
      break
    end
    3: begin
      return, 4
      break
    end
    4: begin
      return, 4
      break
    end
    5: begin
      return, 8
      break
    end
    6: begin
      return, 8
      break
    end
    9: begin
      return, 16
      break
    end
    12: begin
      return, 2
      break
    end
    13: begin
      return, 4
      break
    end
    14: begin
      return, 8
      break
    end
    15: begin
      return, 8
      break
    end    
    else: begin
      return, 4
    end
  endswitch

End

;�����зֿ鴦��
Pro filter_via_all, input_file_fid, output_file, sg_parameter, true_parameter
  
  compile_opt idl2
  
  envi_file_query, input_file_fid, dims=dims, ns=ns, nl=nl, nb=nb, data_type=data_type, interleave=interleave
  
  data = make_array(ns, nl, nb, type=data_type)
  for i=0, nb-1 do begin
  
    data[*, *, i] = envi_get_data(fid=input_file_fid, dims=dims, pos=i)
  
  endfor
  
  true_data = temporary(data)
  
  for i=0, sg_parameter[4]-1 do begin
  
    sg_data = Sg_filter(true_data, sg_parameter[0:3])
    true_data = Max_filter(sg_data, true_data, true_parameter)  
  
  endfor
   
  map_info = envi_get_map_info(fid=input_file_fid)
  
  envi_write_envi_file, sg_data, out_name=output_file, map_info=map_info
  envi_write_envi_file, true_data, out_name=output_file+'_true', map_info=map_info
  
End

;���зֿ鴦��
Pro filter_via_tile, input_file_fid, output_file, sg_parameter, true_parameter

  compile_opt idl2
  
  envi_file_query, input_file_fid, dims=dims, ns=ns, nl=nl, nb=nb, data_type=data_type, interleave=interleave

  openw, unit, output_file, /get_lun
  output_file2 = output_file+'_true'
  openw, unit2, output_file2, /get_lun
    
  tiles_num = 10
  tile_lines = [nl/tiles_num, nl/tiles_num, $
                nl/tiles_num, nl/tiles_num, $
                nl/tiles_num, nl/tiles_num, $
                nl/tiles_num, nl/tiles_num, $
                nl/tiles_num, nl-nl/tiles_num*9]
  print, tile_lines
  
; ѭ���������Tile������ 
  for i=0, tiles_num-1 do begin
    
;   ��ȡ Tiles[i]������
    data = make_array(ns, tile_lines[i], nb, type=data_type)           
    for j=0, nb-1 do begin
      
      data[*, *, j] = envi_get_data(fid=input_file_fid, $
      dims=[dims[0], dims[1], dims[2], i*nl/tiles_num, i*nl/tiles_num+tile_lines[i]-1], $
      pos=j)
      
    endfor

;################################��tile���ݽ��д���###############################################################    
    true_data = temporary(data)  
    for k=0, sg_parameter[4]-1 do begin
  
      sg_data = Sg_filter(true_data, sg_parameter[0:3])
      true_data = Max_filter(sg_data, true_data, true_parameter)  
  
    endfor
     
    ;��dataת���BIL��ʽ�ľ���
    sg_data = transpose(temporary(sg_data), [0, 2, 1])
    true_data = transpose(temporary(true_data), [0, 2, 1])
;################################tile���ݴ������#################################################################
    
;   ��tileд���ļ� 
    writeu, unit, sg_data
    writeu, unit2, true_data
    
    print, '��', i, '��'
  
  endfor
  
  free_lun, unit
  free_lun, unit2
  
  envi_setup_head, fname=output_file, ns=ns, nl=nl, nb=nb, $ 
  data_type=data_type, offset=0, interleave=1, $
  descrip='Test routine output', /write, /open
  
  envi_setup_head, fname=output_file2, ns=ns, nl=nl, nb=nb, $ 
  data_type=data_type, offset=0, interleave=1, $
  descrip='Test routine output', /write, /open  
  
End

;Main Pro
Pro Sg_filter_spectrum

  compile_opt idl2
  
  envi, /restore_base_save_files
  envi_batch_init
  
  input_file = dialog_pickfile(title='ѡ����˲����ļ�')
  if (input_file eq '') then return
  
  output_file = dialog_pickfile(title='ѡ������ļ�', /WRITE)
  if (output_file eq '') then return
  
  wbase = widget_auto_base(title='�˲�����')
  
  wlabel = widget_label(wbase, value='Savitzky-Golay�˲�����������')
  
  list = ['nleft  :', $
          'nright :', $
          'order  :', $
          'degree :', $
          'times  :']
  vals = [2, 2, 0, 2, 1]
  wedit = widget_edit(wbase, uvalue='sg_parameter', list=list, vals=vals, dt=12, /auto, select_prompt='ѡ�е��˲�����', /frame)
  
  wlabel2 = widget_label(wbase, value='ȡ��ֵ��������')
  
  wstring = widget_string(wbase, uvalue='true_parameter', prompt='����ȡСֵ�Ĳ��κ�(���κŴ�1����)', default='4, 5, 6, 16, 17', /auto)
  
  list2 = ['ȡСֵ', 'ȡ��ֵ']
  wtoggle = widget_toggle(wbase, uvalue='is_truedata', prompt='�Ƿ�����ϲ��ν���ȡСֵ', list=list2, /auto)
  
  wresult = auto_wid_mng(wbase)
  if (wresult.accept eq 0) then return
  
  ;sg_parameterΪsg�˲����Ĳ���, sg_paramenter[nleft, nright, order, degree, times]
  sg_parameter = wresult.sg_parameter
  ;true_parameterΪȡСֵ�Ĳ��κ�
  true_parameter = wresult.true_parameter
  
  is_truedata = wresult.is_truedata
  
  envi_open_file, input_file, r_fid=fid
  if (fid eq -1) then begin
      dialog_return = dialog_message(['���ļ�ʧ�ܣ�', '���ļ��޷�ʹ��envi_open_file����'], title='������Ϣ', /information)
      return    
  endif
  envi_file_query, fid, dims=dims, ns=ns, nl=nl, nb=nb, data_type=data_type
  
  if (is_truedata eq 0) then begin
    ;������Ĳ��κ��ַ���ת��Ϊuint������
    true_parameter = strsplit(strcompress(true_parameter), ',', /extract)
    ;���κ�ת��Ϊ����λ��  
    true_parameter = uint(true_parameter) - 1
    if (max(true_parameter) gt nb-1) then begin
      dialog_return = dialog_message(['���벨�κ�����', '���κŴ����ļ���������'], title='������Ϣ', /information)
      return
    endif
  endif else begin
    true_parameter = []
  endelse
  
  print, sg_parameter, true_parameter
  
  file_size = ns*nl*nb*data_type_to_byte(data_type)
  
  ;����300M����зֿ鴦��
  max_file_size = 300*1024*1024
  
  if (file_size ge max_file_size) then begin
;  if (file_size ne 0) then begin
    
    print, '�ֿ鴦��'
    filter_via_tile, fid, output_file, sg_parameter, true_parameter
    
  endif else begin
  
    print, '���崦��'   
    filter_via_all, fid, output_file, sg_parameter, true_parameter
    
  endelse
  
  envi_batch_exit

End