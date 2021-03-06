function testIKGrasp(geometry)
% geometry    -- 1 grasp a box
%             -- 2 grasp a cylinder
% NOTEST
checkDependency('spotless');
addpath(fullfile(pwd,'..'));
if(nargin<1)
  geometry = 2;
end
checkDependency('lcmgl');
% hand = RigidBodyManipulator('../../urdf/s-model_articulated_fourbar_remove_package.urdf',struct('floating',true));
hand = RigidBodyManipulator([getDrakePath,'/examples/IRB140/urdf/irb_140_robotiq_simple_ati.urdf'],struct('floating',true));

hand_tip1 = hand.findLinkId('finger_1_link_3');
hand_tip2 = hand.findLinkId('finger_2_link_3');
hand_tip3 = hand.findLinkId('finger_middle_link_3');
[hand_jl,hand_ju] = hand.getJointLimits();
hand_ju(hand.getBody(hand_tip1).position_num) = pi/12;
hand_ju(hand.getBody(hand_tip2).position_num) = pi/12;
hand_ju(hand.getBody(hand_tip3).position_num) = pi/12;
hand_ju(hand.getBody(hand.findJointId('finger_1_joint_1')).position_num) = pi/4;
hand_ju(hand.getBody(hand.findJointId('finger_2_joint_1')).position_num) = pi/4;
hand_ju(hand.getBody(hand.findJointId('finger_middle_joint_1')).position_num) = pi/4;
hand_ju(hand.getBody(hand.findJointId('finger_1_joint_0')).position_num) = pi/6;
hand_ju(hand.getBody(hand.findJointId('finger_2_joint_0')).position_num) = pi/6;
hand_ju(hand.getBody(hand.findJointId('finger_middle_joint_0')).position_num) = pi/6;
hand = hand.setJointLimits(hand_jl,hand_ju);
hand = compile(hand);
hand_tip_pt = zeros(3,3);
hand_tip_pt_normal = zeros(3,3);
geo_tip1 = hand.getBody(hand_tip1).getCollisionGeometry;
hand_tip_collision_pt1 = geo_tip1{1}.getTerrainContactPoints();
hand_tip_pt(:,1) = mean(hand_tip_collision_pt1(:,1:4),2);
hand_tip_pt_normal(:,1) = cross(hand_tip_collision_pt1(:,2)-hand_tip_collision_pt1(:,1),hand_tip_collision_pt1(:,3)-hand_tip_collision_pt1(:,2));
hand_tip_pt_normal(:,1) = hand_tip_pt_normal(:,1)/norm(hand_tip_pt_normal(:,1));
geo_tip2 = hand.getBody(hand_tip2).getCollisionGeometry();
hand_tip_collision_pt2 = geo_tip2{1}.getTerrainContactPoints();
hand_tip_pt(:,2) = mean(hand_tip_collision_pt2(:,1:4),2);
hand_tip_pt_normal(:,2) = cross(hand_tip_collision_pt2(:,2)-hand_tip_collision_pt2(:,1),hand_tip_collision_pt2(:,3)-hand_tip_collision_pt2(:,2));
hand_tip_pt_normal(:,2) = hand_tip_pt_normal(:,2)/norm(hand_tip_pt_normal(:,2));
geo_tip3 = hand.getBody(hand_tip3).getCollisionGeometry();
hand_tip_collision_pt3 = geo_tip3{1}.getTerrainContactPoints();
hand_tip_pt(:,3) = mean(hand_tip_collision_pt3(:,1:4),2);
hand_tip_pt_normal(:,3) = cross(hand_tip_collision_pt3(:,2)-hand_tip_collision_pt3(:,1),hand_tip_collision_pt3(:,3)-hand_tip_collision_pt3(:,2));
hand_tip_pt_normal(:,3) = hand_tip_pt_normal(:,3)/norm(hand_tip_pt_normal(:,3));

finger_1_link_2 = hand.findLinkId('finger_1_link_2');
finger_2_link_2 = hand.findLinkId('finger_2_link_2');
finger_3_link_2 = hand.findLinkId('finger_middle_link_2');
finger_1_link_1 = hand.findLinkId('finger_1_link_1');
finger_2_link_1 = hand.findLinkId('finger_2_link_1');
finger_3_link_1 = hand.findLinkId('finger_middle_link_1');
palm = hand.findLinkId('palm');

q0 = getZeroConfiguration(hand);
kinsol0 = hand.doKinematics(q0,0*q0,struct('use_mex',false));
palm_pos0 = hand.forwardKin(kinsol0,palm,[0;0;0]);

v = hand.constructVisualizer();
if(geometry == 1)
  box_size = [0.2;0.04;0.04];
  verts = repmat(box_size/2,1,8).*[1 1 1 1 -1 -1 -1 -1;1 1 -1 -1 1 1 -1 -1;1 -1 1 -1 1 -1 1 -1];
  ikgrasp = SynthesizeGraspFreeFaces(verts,3,1,0.8);%,struct('lin_fc_flag',true,'num_fc_edges',4));
  lcmgl = drake.util.BotLCMGLClient(lcm.lcm.LCM.getSingleton,'box');
  lcmgl.glColor3f(0,0,1);
  lcmgl.box([0;0;0],box_size);
  lcmgl.switchBuffers();
elseif(geometry == 2)
  cylinder_radius = 0.04;
  cylinder_height = 0.1;
  cylinder_quat = [1;0;0;0];
  ikgrasp = SynthesizeGraspCylinderSide(cylinder_quat,palm_pos0+[0.13;0;0.0],cylinder_radius,cylinder_height,3,2,struct('robot',hand,'lin_fc_flag',true,'num_fc_edges',4));
%   lcmgl = drake.util.BotLCMGLClient(lcm.lcm.LCM.getSingleton,'cylinder');
%   lcmgl.glColor3f(0,0,1);
%   lcmgl.glTranslated(0,0,-cylinder_height);
%   lcmgl.cylinder(zeros(3,1),cylinder_radius,cylinder_radius,cylinder_height*2,20,20);
%   lcmgl.glTranslated(0,0,cylinder_height);
end
% 

% ikgrasp = ikgrasp.assignGraspFingerPointNormal([hand_tip1 hand_tip2 hand_tip3],hand_tip_pt,hand_tip_pt_normal);
hand_grasp_vert1 = 0.8*hand_tip_collision_pt1(:,1:4)+0.2*bsxfun(@times,mean(hand_tip_collision_pt1(:,1:4),2),ones(1,4));
hand_grasp_vert2 = 0.8*hand_tip_collision_pt2(:,1:4)+0.2*bsxfun(@times,mean(hand_tip_collision_pt2(:,1:4),2),ones(1,4));
hand_grasp_vert3 = 0.8*hand_tip_collision_pt3(:,1:4)+0.2*bsxfun(@times,mean(hand_tip_collision_pt3(:,1:4),2),ones(1,4));
ikgrasp = ikgrasp.assignGraspFingerFaceNormal([hand_tip1 hand_tip2 hand_tip3],{hand_grasp_vert1;hand_grasp_vert2;hand_grasp_vert3},hand_tip_pt_normal);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(finger_1_link_2,0);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(finger_2_link_2,0);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(finger_3_link_2,0);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(finger_1_link_1,0);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(finger_2_link_1,0);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(finger_3_link_1,0);
% ikgrasp = ikgrasp.addObject2LinkCollisionAvoidance(palm,0);
base_link = hand.findLinkId('base_link');
ikgrasp = ikgrasp.fixLinkPosture(base_link,kinsol0.T{base_link}(1:3,4),rotmat2quat(kinsol0.T{base_link}(1:3,1:3)));
ikgrasp.res_tol = 0.001;
ikgrasp.itr_max = 300;
ikgrasp.plot_iteration = true; % Set this to false if you do not want to visualize the intermediate result, and want to make optimization faster.
ikgrasp.alpha_covW = 0.05;
solver_sol = ikgrasp.optimize();
[sol,sol_bilinear] = ikgrasp.retrieveSolution(solver_sol);

v.draw(0,[sol.q;0*sol.q]);
end
