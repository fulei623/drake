
if(simulink_FOUND)
  add_mex(DCSFunction DCSFunction.cpp)
endif()

if(lcm_FOUND)
  add_library_with_exports(LIB_NAME drakeLCMSystem SOURCE_FILES LCMSystem.cpp)
  add_dependencies(drakeLCMSystem drake_lcmtypes_hpp)
  target_link_libraries(drakeLCMSystem lcm)
  if(WIN32)
    target_link_libraries(drakeLCMSystem ws2_32)
  endif()

  pods_install_libraries(drakeLCMSystem)
  drake_install_headers(LCMSystem.h)
  pods_install_pkg_config_file(drake-lcm-system
    LIBS -ldrakeLCMSystem
    REQUIRES lcm
    VERSION 0.0.1)
endif()

add_subdirectory(frames)
add_subdirectory(framework)
add_subdirectory(plants)
add_subdirectory(trajectories)
add_subdirectory(controllers)
add_subdirectory(robotInterfaces)
add_subdirectory(lcm)

drake_install_headers(
  cascade_system.h
  feedback_system.h
  LinearSystem.h
  n_ary_state.h
  n_ary_system.h
  pd_control_system.h
  Simulation.h
  System.h)

add_subdirectory(test)
