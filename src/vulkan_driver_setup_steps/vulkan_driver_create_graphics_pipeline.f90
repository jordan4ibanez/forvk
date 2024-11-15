module vulkan_driver_create_graphics_pipeline
  use, intrinsic :: iso_c_binding
  use :: vulkan_shader_compiler
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_graphics_pipeline(logical_device, vertex_shader_module, fragment_shader_module)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkShaderModule
    integer(c_int64_t), intent(inout) :: vertex_shader_module
    ! VkShaderModule
    integer(c_int64_t), intent(inout) :: fragment_shader_module
    type(vk_pipeline_shader_stage_create_info) :: vertex_shader_stage_info, fragment_shader_stage_info
    character(len = 5, kind = c_char), target :: vert_p_name, frag_p_name
    type(vk_pipeline_shader_stage_create_info), dimension(2) :: shader_stages
    ! VkDynamicState
    integer(c_int32_t), dimension(2), target :: dynamic_states
    type(vk_pipeline_dynamic_state_create_info) :: dynamic_state_create_info
    type(vk_pipeline_vertex_input_state_create_info) :: vertex_input_create_info

    ! First compile GLSL into shader modules.
    vertex_shader_module = compile_glsl_shaders(logical_device, "vertex.vert")
    fragment_shader_module = compile_glsl_shaders(logical_device, "fragment.frag")

    ! Next, Create the vertex shader stage info.
    vertex_shader_stage_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%SHADER_STAGE_CREATE_INFO
    vertex_shader_stage_info%stage = VK_SHADER_STAGE_VERTEX_BIT
    vertex_shader_stage_info%module = vertex_shader_module
    vert_p_name = "main"//achar(0)
    vertex_shader_stage_info%p_name = c_loc(vert_p_name)

    ! Then, create the fragment shader stage create info.
    fragment_shader_stage_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%SHADER_STAGE_CREATE_INFO
    fragment_shader_stage_info%stage = VK_SHADER_STAGE_FRAGMENT_BIT
    fragment_shader_stage_info%module = fragment_shader_module
    frag_p_name = "main"//achar(0)
    fragment_shader_stage_info%p_name = c_loc(frag_p_name)

    ! Put them into an array.
    shader_stages = [vertex_shader_stage_info, fragment_shader_stage_info]

    ! Set up dynamic states for the pipeline.
    dynamic_states = [VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR]

    dynamic_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%DYNAMIC_STATE_CREATE_INFO
    dynamic_state_create_info%dynamic_state_count = size(dynamic_states)
    dynamic_state_create_info%p_dynamic_states = c_loc(dynamic_states)

    ! Create vertex input create info.




    call vk_destroy_shader_module(logical_device, fragment_shader_module, c_null_ptr)
    call vk_destroy_shader_module(logical_device, vertex_shader_module, c_null_ptr)
  end subroutine create_graphics_pipeline


end module vulkan_driver_create_graphics_pipeline
