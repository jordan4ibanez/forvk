module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  use :: directory
  implicit none


contains


  subroutine compile_glsl_shaders()
    implicit none

    type(c_ptr) :: shader_compiler_pointer
    type(directory_reader) :: reader
    integer(c_int32_t) :: i

    shader_compiler_pointer = shaderc_compiler_initialize()


    call reader%read_directory("./shaders/")

    do i = 1,reader%file_count
      print*,reader%files(i)
    end do

    call shaderc_compiler_release(shader_compiler_pointer)
  end subroutine compile_glsl_shaders


end module vulkan_shader_compiler
