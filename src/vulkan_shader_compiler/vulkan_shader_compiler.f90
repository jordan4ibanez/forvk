module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  use :: string_f90
  use :: directory
  implicit none


contains


  subroutine compile_glsl_shaders()
    implicit none

    type(c_ptr) :: shader_compiler_pointer
    type(directory_reader) :: reader
    integer(c_int32_t) :: i
    character(len = :, kind = c_char), pointer :: shader_path, file_name
    character(len = :, kind = c_char), allocatable :: file_extension, file_name_without_extension

    shader_compiler_pointer = shaderc_compiler_initialize()

    call reader%read_directory("./shaders/")

    do i = 1,reader%file_count

      ! This is so I don't have to keep typing this out lol. (No allocation happening)
      file_name => reader%files(i)%get_pointer()

      file_extension = string_get_file_extension(file_name)

      if (file_extension /= "vert" .and. file_extension /= "frag") then
        cycle
      end if

      file_name_without_extension = string_get_left_of_character(file_name, ".")

      allocate(character(len = len("./shaders/") + len(file_name), kind = c_char) :: shader_path)
      shader_path = "./shaders/"//reader%files(i)%get_pointer()

      print*,shader_path

      deallocate(shader_path)
    end do

    call shaderc_compiler_release(shader_compiler_pointer)
  end subroutine compile_glsl_shaders


end module vulkan_shader_compiler
