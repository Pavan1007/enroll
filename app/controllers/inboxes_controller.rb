class InboxesController < ApplicationController
  before_action :find_inbox_provider, except: [:msg_to_portal]
  before_action :find_hbx_profile, only: [:new, :create]
  before_action :find_message, only: [:show, :destroy]
  before_action :set_inbox_and_assign_message, only: [:create]

  def new
    @new_message = @inbox_provider.inbox.messages.build
  end

  def create
    @new_message.folder = Message::FOLDER_TYPES[:inbox]

    @inbox.post_message(@new_message)
    if @inbox.save
      create_sent_message
      flash[:notice] = "Successfully sent message."
      redirect_to successful_save_path
    else
      render "new"
    end
  end

  def show
    @message.update_attributes(message_read: true)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy

    #@message.destroy
    if current_user.has_hbx_staff_role?
      if params.has_key?(:user)
        person = Person.find(params[:id])
      elsif params.has_key?(:broker_agency_profile)
        person = BrokerAgencyProfile.find(params[:person_id])
      else
        person = @inbox_provider
      end
    elsif params.has_key?(:mailbox)
      person = BrokerAgencyProfile.find(params[:person_id])
    elsif current_user.has_broker_role?
      person = Person.find(params[:id])
    end
    message = person.inbox.messages.where(id: params[:message_id]).first
    message.update_attributes(folder: Message::FOLDER_TYPES[:deleted])
      if person.inbox.save
        flash[:notice] = "Successfully deleted inbox message."

        if params.has_key?(:user)
          redirect_to broker_agencies_profile_path(person, :user=>'admin', :folder=>'inbox')

        elsif params.has_key?(:broker_agency_profile)
          redirect_to broker_agencies_profile_path(person, :tab=>'inbox', :folder=>'inbox')
        else
          redirect_to exchanges_hbx_profiles_path(person, :tab=>'inbox', :folder=>'inbox')
        end
      end

    if current_user.has_employer_staff_role?
      employer = EmployerProfile.find(params["id"])
      message = employer.inbox.messages.where(id: params[:message_id]).first
      message.update_attributes(folder: Message::FOLDER_TYPES[:deleted])
      if employer.inbox.save
        flash[:notice] = "Successfully deleted inbox message."
        redirect_to employers_employer_profile_path(employer.id, :tab=>'inbox', :folder=>'inbox')
      end
    end
    if current_user.has_consumer_role? || current_user.has_employee_role?
      person = Person.find(params[:person_id])
      message = person.inbox.messages.where(id: params[:message_id]).first
      message.update_attributes(folder: Message::FOLDER_TYPES[:deleted])
      if person.inbox.save
        flash[:notice] = "Successfully deleted inbox message."
        redirect_to inbox_insured_families_path(person.id, :tab=>'messages', :folder=>'inbox')
      end
    end
      @message.update_attributes(folder: Message::FOLDER_TYPES[:deleted])

    end


  private

  def create_sent_message
    sent_message = @new_message.dup
    sent_message.folder = Message::FOLDER_TYPES[:sent]
    sent_message.parent_message_id = @new_message._id
    inbox = @profile.inbox
    inbox.post_message(sent_message)
    inbox.save!
  end

  def find_hbx_profile
    @profile = HbxProfile.find(params["profile_id"])
  end

  def find_message
    if params.has_key?(:user)
      @person = Person.find(params[:id])
      @message = @person.inbox.messages.by_message_id(params["message_id"]).to_a.first
    else
      @message = @inbox_provider.inbox.messages.by_message_id(params["message_id"]).to_a.first
    end
  end

  def set_inbox_and_assign_message
    @inbox = @inbox_provider.inbox
    @new_message = Message.new(params.require(:message).permit!)
  end
end
