module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  use :: shaderc_types
  use :: string_f90
  use :: directory
  use :: files_f90
  implicit none


contains


  subroutine compile_glsl_shaders()
    implicit none

    type(c_ptr) :: shader_compiler_options_pointer, shader_compiler_pointer
    type(directory_reader) :: path_reader
    type(file_reader) :: reader
    integer(c_int32_t) :: i, shader_type
    character(len = :, kind = c_char), pointer :: shader_path, file_name, shader_text_data, entry_point
    character(len = :, kind = c_char), allocatable :: file_extension, file_name_without_extension
    type(c_ptr) :: ptr_compilation_result
    type(shaderc_include_result), pointer :: compilation_result_pointer

    print"(A)","[ShaderC]: Compiling shaders from GLSL to SPIR-V."

    shader_compiler_options_pointer = shaderc_compile_options_initialize()

    call shaderc_compile_options_set_generate_debug_info(shader_compiler_options_pointer)

    shader_compiler_pointer = shaderc_compiler_initialize()

    call path_reader%read_directory("./shaders/")

    allocate(character(len = 5, kind = c_char) :: entry_point)
    entry_point = "main"//achar(0)

    do i = 1,path_reader%file_count

      ! This is so I don't have to keep typing this out lol. (No allocation happening)
      file_name => path_reader%files(i)%get_pointer()

      file_extension = string_get_file_extension(file_name)

      if (file_extension /= "vert" .and. file_extension /= "frag") then
        cycle
      end if

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

      ptr_compilation_result = shaderc_compile_into_spv(shader_compiler_pointer, c_loc(shader_text_data), int(len(shader_text_data), c_size_t) - 1, shader_type, c_loc(file_name), c_loc(entry_point), shader_compiler_options_pointer)
      call c_f_pointer(ptr_compilation_result, compilation_result_pointer)

      if (shaderc_result_get_num_errors(ptr_compilation_result) /= 0) then
        if (string_from_c(compilation_result_pointer%content) /= "") then
          error stop "[ShaderC] Error: Shader compilation failed."//achar(10)//string_from_c(compilation_result_pointer%content)
        else
          error stop "[ShaderC] Error: Could not transmit error!"
        end if
      end if

      print*,compilation_result_pointer%content_length

      call shaderc_result_release(ptr_compilation_result)

      call reader%destroy()
      deallocate(shader_path)
    end do

    deallocate(entry_point)

    call path_reader%destroy()

    call shaderc_compiler_release(shader_compiler_pointer)

    call shaderc_compile_options_release(shader_compiler_options_pointer)
  end subroutine compile_glsl_shaders


end module vulkan_shader_compiler
