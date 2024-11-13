module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  use :: string_f90
  use :: directory
  use :: files_f90
  implicit none


contains


  subroutine compile_glsl_shaders()
    implicit none

    type(c_ptr) :: shader_compiler_pointer
    type(directory_reader) :: path_reader
    type(file_reader) :: reader
    integer(c_int32_t) :: i, shader_type
    character(len = :, kind = c_char), pointer :: shader_path, file_name, shader_text_data, entry_point
    character(len = :, kind = c_char), allocatable :: file_extension, file_name_without_extension
    type(c_ptr) :: raw_shader

    print"(A)","[ShaderC]: Compiling shaders from GLSL to SPIR-V."

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

      raw_shader = c_null_ptr

      raw_shader = shaderc_compile_into_spv(shader_compiler_pointer, c_loc(shader_text_data), int(len(shader_text_data), c_size_t), shader_type, c_loc(file_name), c_loc(entry_point), c_null_ptr)

      print*,raw_shader

      call reader%destroy()
      deallocate(shader_path)
    end do

    call path_reader%destroy()

    call shaderc_compiler_release(shader_compiler_pointer)
  end subroutine compile_glsl_shaders


end module vulkan_shader_compiler
