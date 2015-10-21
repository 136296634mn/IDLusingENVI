Pro Cal_ndvi, input_file_fid, pos, output_file_name
  
  compile_opt idl2
  
  envi_file_query, input_file_fid, dims=dims
  
;  math_doit, fid=[input_file_fid, input_file_fid, input_file_fid], pos=pos, $
;  dims=dims, out_bname='ndvi', out_name=output_file_name, $
;  exp='(float(b3)-float(b2))/(float(b3)+float(b2))'
  
  envi_doit, 'math_doit', fid=[input_file_fid, input_file_fid, input_file_fid], pos=pos, $
  dims=dims, out_bname='ndvi', out_name=output_file_name, $
  exp='(float(b3)-float(b2))/(float(b3)+float(b2))'
  
End


Pro Cal_ndvi_batch
  
  compile_opt idl2
  
  envi, /restore_base_save_files
  envi_batch_init
  
  input_files_path = dialog_pickfile(title='��ѡ�������ļ�����·��', /directory)
  if (input_files_path eq '') then return
  input_files = file_search(input_files_path, '*.ld3', /fold_case, count=count)
  if (count eq 0) then begin
    dialog_return = dialog_message([input_files_path, '��û��.ld3�ļ�'], title='������Ϣ', /information)
    return
  endif
  
  base = widget_auto_base(title='��ѡ�����NDVI�Ĳ���')
  
  list = ['��ɫ���ζ�Ӧ�Ĳ��κţ�   ', '��ɫ���ζ�Ӧ�Ĳ��κţ�   ', '�����Ⲩ�ζ�Ӧ�Ĳ��κţ� ']
  values = [1, 3, 4]
  we = widget_edit(base, uvalue='edit', list=list, dt=1, vals=values, /auto)

  result = auto_wid_mng(base)
  if (result.accept eq 0) then return  
  
  ;���κ�ת��Ϊ����λ��
  pos = [result.edit[0]-1, result.edit[1]-1, result.edit[2]-1]
  
  output_files_path = dialog_pickfile(title='��ѡ������ļ�·��', /directory)
  if (output_files_path eq '') then return
  
  for i=0, count-1 do begin
    
    envi_open_file, input_files[i], r_fid=fid
    if (fid eq -1) then begin
      print, '��', input_files[i], 'failed!'
      continue 
    endif
    
    output_file_name = output_files_path + file_basename(input_files[i], '.ld3') + '_ndvi.ld3'
    
    cal_ndvi, fid, pos, output_file_name
      
  endfor
  
  envi_batch_exit
    
End