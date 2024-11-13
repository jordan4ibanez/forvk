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

    ! const shaderc_compiler_t compiler,
    ! const char* source_text,
    ! size_t source_text_size,
    ! shaderc_shader_kind shader_kind,
    ! const char* input_file_name,
    ! const char* entry_point_name,
    ! const shaderc_compile_options_t additional_options


    function shaderc_compile_into_spv(shader_compiler_pointer, source_text, source_text_size, shader_kind, input_file_name, entry_point_name, additional_options) result(raw_data) bind(c, name = "shaderc_compile_into_spv")
      use, intrinsic :: iso_c_binding
      implicit none

      type(c_ptr), intent(in), value :: shader_compiler_pointer
      type(c_ptr), intent(in), value :: source_text
      integer(c_size_t), intent(in), value :: source_text_size
      integer(c_int32_t), intent(in), value :: shader_kind
      type(c_ptr), intent(in), value :: input_file_name
      type(c_ptr), intent(in), value :: entry_point_name
      type(c_ptr), intent(in), value :: additional_options
      type(c_ptr) :: raw_data
    end function shaderc_compile_into_spv


  end interface


end module shaderc_bindings
