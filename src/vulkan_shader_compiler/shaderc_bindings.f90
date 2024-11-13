module shaderc_bindings
  use, intrinsic :: iso_c_binding
  implicit none

  ! I did not figure this out on my own.
  ! https://www.reddit.com/r/vulkan/comments/ecnjn7/converting_shader_source_to_spirv_on_the_fly/
  ! https://github.com/jbikker/lighthouse2/blob/master/lib/rendercore_vulkan_rt/vulkan_shader.cpp
  ! https://github.com/google/shaderc/blob/main/libshaderc/include/shaderc/shaderc.h

  
  ! These enums were manually translated from the enum struct.

  integer(c_int32_t), parameter :: shaderc_glsl_vertex_shader = 0
  integer(c_int32_t), parameter :: shaderc_glsl_fragment_shader = 1


  interface


    function shaderc_compiler_initialize() result(shader_compiler_pointer) bind(c, name = "shaderc_compiler_initialize")
      use, intrinsic :: iso_c_binding
      implicit none

      type(c_ptr) :: shader_compiler_pointer
    end function shaderc_compiler_initialize


    subroutine shaderc_compiler_release(shader_compiler_pointer) bind(c, name = "shaderc_compiler_release")
      use, intrinsic :: iso_c_binding
      implicit none

      type(c_ptr), intent(in), value :: shader_compiler_pointer
    end subroutine shaderc_compiler_release


    ! function shaderc_compile_into_spv() result(unknown) bind(c, name = "shaderc_compile_into_spv")
    !   use, intrinsic :: iso_c_binding
    !   implicit none

    !   integer(c_int32_t) :: unknown
    ! end function shaderc_compile_into_spv


  end interface


end module shaderc_bindings
