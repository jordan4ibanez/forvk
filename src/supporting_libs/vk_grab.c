#include <stdlib.h>
#include <vulkan/vulkan_core.h>

VkInstance *vk_grab_instance_pointer()
{
  void *data = malloc(sizeof(VkInstance));

  assert(data);

  return (VkInstance *)data;
}