module shaderc_bindings
  use, intrinsic :: iso_c_binding
  implicit none

  ! I did not figure this out on my own.
  ! https://www.reddit.com/r/vulkan/comments/ecnjn7/converting_shader_source_to_spirv_on_the_fly/
  ! https://github.com/jbikker/lighthouse2/blob/master/lib/rendercore_vulkan_rt/vulkan_shader.cpp
  ! https://github.com/google/shaderc/blob/main/libshaderc/include/shaderc/shaderc.h

  interface

    function shaderc_compile_into_spv() result(unknown) bind(c, name = "shaderc_compile_into_spv")
      use, intrinsic :: iso_c_binding
      implicit none

      integer(c_int32_t) :: unknown
    end function shaderc_compile_into_spv

  end interface


end module shaderc_bindings