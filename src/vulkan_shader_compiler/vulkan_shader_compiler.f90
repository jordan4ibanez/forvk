module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  use :: string_f90
  use :: directory
  use :: files_f90
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  !* Compile a shader in the shaders folder.
  function compile_glsl_shaders(logical_device, shader_file_name) result(shader_module)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    character(len = *, kind = c_char), intent(in) :: shader_file_name
    integer(c_int64_t) :: shader_module
    type(c_ptr) :: shader_compiler_options_pointer, shader_compiler_pointer
    type(file_reader) :: reader
    integer(c_int32_t) :: shader_type
    character(len = :, kind = c_char), pointer :: shader_path, c_file_name_pointer, shader_text_data, entry_point, error_message
    character(len = :, kind = c_char), allocatable :: file_extension, file_name_without_extension
    type(c_ptr) :: compilation_result_ptr, raw_spir_v_data_ptr
    integer(c_size_t) :: raw_spir_v_data_size
    type(vk_shader_module_create_info), target :: create_info

    file_extension = string_get_file_extension(shader_file_name)

    if (file_extension /= "vert" .and. file_extension /= "frag") then
      error stop "[ShaderC]: File ["//shader_file_name//"] is not a shader."
    end if

    print"(A)","[ShaderC]: Compiling shader ["//shader_file_name//"] from GLSL to SPIR-V."

    allocate(character(len = len(shader_file_name) + 1, kind = c_char) :: c_file_name_pointer)
    c_file_name_pointer = shader_file_name//achar(0)

    shader_compiler_options_pointer = shaderc_compile_options_initialize()

    call shaderc_compile_options_set_generate_debug_info(shader_compiler_options_pointer)

    shader_compiler_pointer = shaderc_compiler_initialize()

    allocate(character(len = 5, kind = c_char) :: entry_point)
    entry_point = "main"//achar(0)

    print"(A)","[ShaderC]: Compiling ["//c_file_name_pointer//"]"

    file_name_without_extension = string_get_left_of_character(c_file_name_pointer, ".")

    allocate(character(len = len("./shaders/") + len(c_file_name_pointer), kind = c_char) :: shader_path)
    shader_path = "./shaders/"//c_file_name_pointer

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

    ! Now we compile from GLSL -> SPIR-V binary data.

    compilation_result_ptr = shaderc_compile_into_spv(shader_compiler_pointer, c_loc(shader_text_data), int(len(shader_text_data), c_size_t) - 1, shader_type, c_loc(c_file_name_pointer), c_loc(entry_point), shader_compiler_options_pointer)

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

    ! Create the necessary create info.
    create_info%s_type = VK_STRUCTURE_TYPE%SHADER_MODULE_CREATE_INFO
    create_info%code_size = raw_spir_v_data_size
    create_info%p_code = raw_spir_v_data_ptr

    ! We shall now compile the SPIR-V code into a shader module.
    if (vk_create_shader_module(logical_device, c_loc(create_info), c_null_ptr, shader_module) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create shader module from SPIR-V code for file ["//shader_file_name//"]"
    end if

    ! We can now free everything, we have a fully Fortranified SPIR-V binary in memory.

    call shaderc_result_release(compilation_result_ptr)

    call reader%destroy()

    deallocate(shader_path)
    deallocate(c_file_name_pointer)
    deallocate(entry_point)

    call shaderc_compiler_release(shader_compiler_pointer)

    call shaderc_compile_options_release(shader_compiler_options_pointer)

    print"(A)","[ShaderC]: Shader compilation completed."
  end function compile_glsl_shaders


end module vulkan_shader_compiler
