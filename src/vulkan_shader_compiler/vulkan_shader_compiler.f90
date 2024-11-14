module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  use :: string_f90
  use :: directory
  use :: files_f90
  implicit none


contains


  !* Compile a shader in the shaders folder.
  subroutine compile_glsl_shaders(shader_file_name)
    implicit none

    character(len = *, kind = c_char), intent(in) :: shader_file_name
    type(c_ptr) :: shader_compiler_options_pointer, shader_compiler_pointer
    type(file_reader) :: reader
    integer(c_int32_t) :: i, shader_type, writer_unit, input_output_status
    character(len = :, kind = c_char), pointer :: shader_path, file_name, shader_text_data, entry_point, error_message, compiled_file_name
    character(len = :, kind = c_char), allocatable :: file_extension, file_name_without_extension
    type(c_ptr) :: compilation_result_ptr, raw_spir_v_data_ptr
    integer(c_size_t) :: raw_spir_v_data_size
    integer(1), dimension(:), pointer :: raw_byte_data


    file_extension = string_get_file_extension(file_name)

    if (file_extension /= "vert" .and. file_extension /= "frag") then
      error stop "[ShaderC]: File ["//shader_file_name//"] is not a shader."
    end if

    print"(A)","[ShaderC]: Compiling shader ["//shader_file_name//"] from GLSL to SPIR-V."

    shader_compiler_options_pointer = shaderc_compile_options_initialize()

    call shaderc_compile_options_set_generate_debug_info(shader_compiler_options_pointer)

    shader_compiler_pointer = shaderc_compiler_initialize()

    allocate(character(len = 5, kind = c_char) :: entry_point)
    entry_point = "main"//achar(0)

    print"(A)","[ShaderC]: Compiling ["//file_name//"]"

    file_name_without_extension = string_get_left_of_character(file_name, ".")

    allocate(character(len = len("./shaders/") + len(file_name), kind = c_char) :: shader_path)
    shader_path = "./shaders/"//file_name

    select case(file_extension)
     case("vert")
      shader_type = shaderc_glsl_vertex_shader
     case("frag")
      shader_type = shaderc_glsl_fragment_shader
     case default
      error stop "[ShaderC] Error: Wrong file type intake. ["//file_extension//"]"
    end select

    call reader%read_file(shader_path)

    allocate(character(len = len(reader%file_string) + 1, kind = c_char) :: shader_text_data)
    shader_text_data = reader%file_string//achar(0)

    compilation_result_ptr = shaderc_compile_into_spv(shader_compiler_pointer, c_loc(shader_text_data), int(len(shader_text_data), c_size_t) - 1, shader_type, c_loc(file_name), c_loc(entry_point), shader_compiler_options_pointer)

    if (shaderc_result_get_num_errors(compilation_result_ptr) /= 0) then
      error_message => string_from_c(shaderc_result_get_error_message(compilation_result_ptr))
      if (error_message /= "") then
        error stop "[ShaderC] Error: Shader compilation failed."//achar(10)//error_message
      else
        error stop "[ShaderC] Error: Could not transmit error!"
      end if
    end if

    raw_spir_v_data_size = shaderc_result_get_length(compilation_result_ptr)

    raw_spir_v_data_ptr = shaderc_result_get_bytes(compilation_result_ptr)

    if (.not. c_associated(raw_spir_v_data_ptr)) then
      error stop "[ShaderC] Error: The returned SPIR-V data pointer is null."
    end if

    ! Why yes, we are just transfering this raw data into a byte array.
    call c_f_pointer(raw_spir_v_data_ptr, raw_byte_data, [raw_spir_v_data_size])

    allocate(character(len = len(shader_path) + 7, kind = c_char) :: compiled_file_name)
    compiled_file_name = shader_path//"-spir-v"

    deallocate(compiled_file_name)

    call shaderc_result_release(compilation_result_ptr)

    call reader%destroy()
    deallocate(shader_path)

    deallocate(entry_point)

    call shaderc_compiler_release(shader_compiler_pointer)

    call shaderc_compile_options_release(shader_compiler_options_pointer)

    print"(A)","[ShaderC]: Shader compilation completed."

  end subroutine compile_glsl_shaders


end module vulkan_shader_compiler
