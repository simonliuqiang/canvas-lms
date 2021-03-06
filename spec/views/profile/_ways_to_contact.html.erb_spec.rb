#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../views_helper')

describe "/profile/_ways_to_contact" do
  it "should render" do
    course_with_student
    view_context
    assigns[:email_channels] = []
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:user] = @user
    
    render :partial => "profile/ways_to_contact"
    response.should_not be_nil
  end

  it "should not show a student the confirm link" do
    course_with_student
    view_context
    @user.communication_channels.create!(:path_type => 'email', :path => 'someone@somewhere.com')
    @user.communication_channels.first.state.should == :unconfirmed
    assigns[:email_channels] = @user.communication_channels.to_a
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:user] = @user

    render :partial => "profile/ways_to_contact"
    response.body.should_not match /confirm_channel_link/
  end

  it "should show an admin the confirm link" do
    account_admin_user
    view_context
    @user.communication_channels.create!(:path_type => 'email', :path => 'someone@somewhere.com')
    @user.communication_channels.first.state.should == :unconfirmed
    assigns[:email_channels] = @user.communication_channels.to_a
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:user] = @user

    render :partial => "profile/ways_to_contact"
    response.body.should match /confirm_channel_link/
  end

  it "should not show confirm link for confirmed channels" do
    account_admin_user
    view_context
    @user.communication_channels.create!(:path_type => 'email', :path => 'someone@somewhere.com')
    @user.communication_channels.first.confirm
    @user.communication_channels.first.state.should == :active
    assigns[:email_channels] = @user.communication_channels.to_a
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:user] = @user

    render :partial => "profile/ways_to_contact"
    response.body.should_not match /confirm_channel_link/
  end

  it "should show an admin masquerading as a user the confirm link" do
    course_with_student
    account_admin_user
    view_context(@course, @student, @admin)
    @student.communication_channels.create!(:path_type => 'email', :path => 'someone@somewhere.com')
    @student.communication_channels.first.state.should == :unconfirmed
    assigns[:email_channels] = @student.communication_channels.to_a
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:user] = @student

    render :partial => "profile/ways_to_contact"
    response.body.should match /confirm_channel_link/
  end
end

