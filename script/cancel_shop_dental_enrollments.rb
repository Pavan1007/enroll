# ticket https://devops.dchbx.org/redmine/issues/5142
# this script will
# 1) fix enrollments having the wrong coverage_kind
# 2) cancel any dental enrollments in shop

logger = Logger.new("#{Rails.root}/log/cancel_shop_dental_enrollments.log")

csv = CSV.open("fixed_enrollment_coverage_kind.csv", "w")
csv << %w(hbx_enrollment.household.family.id, hbx_enrollment.id
          hbx_enrollment.coverage_kind, hbx_enrollment.kind  hbx_enrollment.aasm_state
          person employer_name )
ENROLLMENT_CANCELLABLE_STATES = [:auto_renewing, :renewing_coverage_selected, :renewing_transmitted_to_carrier,
                      :renewing_coverage_enrolled, :coverage_selected, :transmitted_to_carrier, :coverage_renewed,
                      :enrolled_contingent, :unverified, :renewing_waived]

batch_size = Family.count / 20
offset = 0

while (offset <= Family.count)
  Family.offset(offset).limit(batch_size).flat_map(&:households).flat_map(&:hbx_enrollments).each do |hbx_enrollment|
    begin
      if (hbx_enrollment.kind == "employer_sponsored") && (hbx_enrollment.coverage_kind == 'dental')

        # cancel any dental enrollments in shop
        if ENROLLMENT_CANCELLABLE_STATES.include? hbx_enrollment.aasm_state.to_sym
          hbx_enrollment.cancel_coverage!
        else
          hbx_enrollment.aasm_state = 'coverage_canceled'
        end

        hbx_enrollment.terminated_on = TimeKeeper.date_of_record

        hbx_enrollment.hbx_enrollment_members.each do |hbx_enrollment_member|
          hbx_enrollment_member.coverage_end_on = hbx_enrollment_member.coverage_start_on
        end

        hbx_enrollment.save
        hbx_enrollment.reload

        if hbx_enrollment.subscriber
          person_name = hbx_enrollment.subscriber.person.first_name + " " + hbx_enrollment.subscriber.person.last_name
        else
          person_name = ""
        end

        if hbx_enrollment.employer_profile
          employer_name = hbx_enrollment.employer_profile.legal_name
        else
          employer_name = ""
        end

        csv << [hbx_enrollment.household.family.id, hbx_enrollment.id, hbx_enrollment.coverage_kind,
                hbx_enrollment.kind, hbx_enrollment.aasm_state, person_name, employer_name]
      end
    rescue Exception => e
      logger.info "Family #{hbx_enrollment.household.family.id} hbx_enrollment #{hbx_enrollment.id} " + e.message
    end
  end
  offset += batch_size
end
