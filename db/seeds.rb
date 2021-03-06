# frozen_string_literal: true

# This seeds the db with data. It is not used in production.
# Use :find_or_create_by! or :first_or_create! when creating objects,
#  or use the class methods in CreateOrSampleLookup for address Lookup:: classes.
#   The address Lookup classes should be seeded by the
#   Rake::Task below, but if they're not or if you need to create a different
#   object, use the methods in CreateOrSampleLookup.

ActionMailer::Base.perform_deliveries = false

puts 'Seeding.......'

THIS_YEAR = Date.current.year
JAN_1 = Date.new(THIS_YEAR, 1, 1)
MAR_31 = Date.new(THIS_YEAR, 3, 31)
APR_1 = Date.new(THIS_YEAR, 4, 1)
JUN_30 = Date.new(THIS_YEAR, 6, 30)

# minimum birthdates (ages)
MIN_BIRTHDAY = (Time.zone.now - 2.weeks)
MAX_BIRTHDAY = (Time.zone.now - 14.years)

# ---------------------------------------------

# Use puts to show the number of records in the database for a given class
def puts_records_in_db(klass)
  puts " ... #{klass.count} #{klass.name.pluralize} now in the db"
end

# ---------------------------------------------

Rake::Task['pie4providers:address_lookups:import_all'].invoke
puts_records_in_db(Lookup::State)
puts_records_in_db(Lookup::County)
puts_records_in_db(Lookup::City)
puts_records_in_db(Lookup::Zipcode)

@user_kate = User.where(email: ENV.fetch('TESTUSER_EMAIL', 'test@test.com')).first_or_create(
  active: true,
  full_name: 'Kate Donaldson',
  greeting_name: 'Kate',
  language: 'english',
  opt_in_email: true,
  opt_in_text: true,
  organization: 'Pie for Providers',
  password: ENV.fetch('TESTUSER_PASS', 'testpass1234!'),
  password_confirmation: ENV.fetch('TESTUSER_PASS', 'testpass1234!'),
  phone_number: '8888888888',
  phone_type: 'cell',
  service_agreement_accepted: true,
  timezone: 'Central Time (US & Canada)'
)

@user_kate.confirm
puts_records_in_db(User)

# ---------------------------------------------
# Children
# ---------------------------------------------

# find_or_create_by! a Child with the full_name,
#  and birthday set randomly between the min_age and max_age.
def child_named(full_name, min_birthday: MIN_BIRTHDAY,
                max_birthday: MAX_BIRTHDAY,
                user: @user_kate)
  Child.find_or_create_by!(user: @user_kate,
                           full_name: full_name,
                           date_of_birth: Faker::Date.between(from: max_birthday, to: min_birthday))
end

maria = child_named('Maria Baca')
kshawn = child_named("K'Shawn Henderson")
marcus = child_named('Marcus Smith')
sabina = child_named('Sabina Akers')
mubiru = child_named('Mubiru Karstensen')
tarq = child_named('Tarquinius Kelly')

puts_records_in_db(Child)

# ---------------------------------------------
# Businesses and Sites
# ---------------------------------------------

business = Business.where(name: 'Happy Seedlings Childcare', user: @user_kate).first_or_create(
  license_type: Licenses.types.keys.first
)

puts_records_in_db(Business)

montana = Lookup::State.find_or_create_by!(name: 'Montana', abbr: 'MT')
big_horn_cty_mt = Lookup::County.find_or_create_by!(name: 'Big Horn', state: montana)
hardin_mt = Lookup::City.find_or_create_by!(state: montana, county: big_horn_cty_mt, name: 'Hardin')
hardin_zip = Lookup::Zipcode.first_or_create!(city: hardin_mt) do
  CreateOrSampleLookup.random_zipcode_or_create(city: hardin_mt)
end

site_prairie_ctr = Site.where(name: 'Prairie Center', business: business).first_or_create(
  address: '8238 Rhinebeck Dr',
  city: hardin_mt,
  county: hardin_mt.county,
  state: montana,
  zip: hardin_zip
)

wisconsin = Lookup::State.find_or_create_by!(name: 'Wisconsin', abbr: 'WI')
vilas_cty_wi = Lookup::County.find_or_create_by!(name: 'Vilas', state: wisconsin)
lac_du_flambeau = Lookup::City.find_by(state: wisconsin, county: vilas_cty_wi, name: 'Lac Du Flambeau')
lac_du_flambeau_zip = Lookup::Zipcode.first_or_create!(city: lac_du_flambeau) do
  CreateOrSampleLookup.random_zipcode_or_create(city: lac_du_flambeau)
end
site_happy_seeds_little_oaks = Site.where(name: 'Little Oaks Growing Center',
                                          business: business).first_or_create(
                                            address: '8201 1st Street',
                                            city: lac_du_flambeau,
                                            state: wisconsin,
                                            zip: lac_du_flambeau_zip,
                                            county: vilas_cty_wi,
                                            qris_rating: 3,
                                            active: true
                                          )

walworth_cty_wi = Lookup::County.find_or_create_by!(name: 'Walworth', state: wisconsin)
elkhorn_wi = Lookup::City.find_or_create_by!(name: 'Walworth', state: wisconsin, county: walworth_cty_wi)
elkhorn_wi_zip = Lookup::Zipcode.first_or_create!(city: elkhorn_wi) do
  CreateOrSampleLookup.random_zipcode_or_create(city: elkhorn_wi)
end

site_happy_seeds_little_sprouts = Site.where(name: 'Little Sprouts Growing Center',
                                             business: business).first_or_create(
                                               address: '123 Bighorn Lane',
                                               city: elkhorn_wi,
                                               state: wisconsin,
                                               zip: elkhorn_wi_zip,
                                               county: walworth_cty_wi,
                                               qris_rating: 3,
                                               active: true
                                             )
puts_records_in_db(Site)

# ---------------------------------------------
# Children at a Child Care Site
# ---------------------------------------------
# TODO: make sure that care did not start before a child was born.
maria_at_prairie_ctr = ChildSite.find_or_create_by!(child: maria, site: site_prairie_ctr,
                                                    started_care: Date.new(THIS_YEAR - 1, 6, 13))
kshawn_at_prairie_ctr = ChildSite.find_or_create_by!(child: kshawn, site: site_prairie_ctr,
                                                     started_care: Date.new(THIS_YEAR - 1, 12, 12))
marcus_at_prairie_ctr = ChildSite.find_or_create_by!(child: marcus, site: site_prairie_ctr,
                                                     started_care: Date.new(THIS_YEAR - 1, 12, 18))
mubiru_at_prairie_ctr = ChildSite.find_or_create_by!(child: mubiru, site: site_prairie_ctr,
                                                     started_care: Date.new(THIS_YEAR, 4, 18))

puts_records_in_db(ChildSite)

# ---------------------------------------------
# Agencies
# ---------------------------------------------

agency_WI = Agency.where(name: "Wisconsin Children's Services",
                         state: wisconsin).first_or_create(
                           active: true
                         )
illinois = Lookup::State.find_or_create_by!(name: 'Illinois', abbr: 'IL')
agency_IL = Agency.where(name: 'Community Child Care Connection',
                         state: illinois).first_or_create(
                           active: true
                         )
massachusetts = Lookup::State.find_or_create_by!(name: 'Massachusetts', abbr: 'MA')
agency_MA = Agency.where(name: "Children's Aid and Family Services",
                         state: massachusetts).first_or_create(
                           active: true
                         )

puts_records_in_db(Agency)

# ---------------------------------------------
# Payments
# ---------------------------------------------

Payment.where(agency: agency_WI, site: site_happy_seeds_little_oaks,
              paid_on: Date.new(THIS_YEAR, 8, 1)).first_or_create(
                care_started_on: JAN_1,
                care_finished_on: MAR_31,
                amount_cents: 85_000,
                discrepancy_cents: 25_000
              )
Payment.where(agency: agency_WI, site: site_happy_seeds_little_sprouts,
              paid_on: Date.new(THIS_YEAR, 8, 1)).first_or_create(
                care_started_on: JAN_1,
                care_finished_on: MAR_31,
                amount_cents: 100_000,
                discrepancy_cents: 0
              )
Payment.where(agency: agency_WI, site: site_happy_seeds_little_sprouts,
              paid_on: Date.new(THIS_YEAR, 8, 10)).first_or_create(
                care_started_on: JAN_1,
                care_finished_on: Date.new(THIS_YEAR, 5, 15),
                amount_cents: 140_000,
                discrepancy_cents: 2_750
              )

puts_records_in_db(Payment)

# ---------------------------------------------
# Subsidy Rules
#
# ---------------------------------------------

county_il_cook = Lookup::County.find_or_create_by!(state: illinois, name: 'Cook')

sr_rule_1 = SubsidyRule.first_or_create!(
  name: 'Rule 1',
  county: county_il_cook,
  state: illinois,
  max_age: 18,
  part_day_rate: 18.00,
  full_day_rate: 32.00,
  part_day_max_hours: 5,
  full_day_max_hours: 12,
  full_plus_part_day_max_hours: 18,
  full_plus_full_day_max_hours: 24,
  part_day_threshold: 5,
  full_day_threshold: 6,
  license_type: Licenses.types.values.sample,
  qris_rating: '3'
)

puts_records_in_db(SubsidyRule)

# ---------------------------------------------
# CaseCycles
# ---------------------------------------------

jan_q1_casecycle = CaseCycle.find_or_create_by!(user: @user_kate,
                                                effective_on: JAN_1,
                                                expires_on: Date.new(THIS_YEAR, 3, 30),
                                                submitted_on: Date.new(THIS_YEAR, 5, 12),
                                                status: :submitted,
                                                copay_frequency: :weekly) do |new_case_cycle|
  # the Monetize attribute must be set within a block; it cannot be set in the find_or_create_by! arguments
  new_case_cycle.copay = 10
end

apr_q2_casecycle = CaseCycle.find_or_create_by!(user: @user_kate,
                                                effective_on: APR_1,
                                                expires_on: Date.new(THIS_YEAR, 6, 30),
                                                submitted_on: Date.new(THIS_YEAR, 7, 15),
                                                status: :submitted,
                                                copay_frequency: :weekly) do |new_case_cycle|
  # the Monetize attribute must be set within a block; it cannot be set in the find_or_create_by! arguments
  new_case_cycle.copay = 10
end

puts_records_in_db(CaseCycle)

# ---------------------------------------------
# Children in a Case Cycle:  ChildCaseCycle
# ---------------------------------------------

jan_q1_kids = [maria, kshawn, marcus]
apr_q2_kids = [maria, kshawn, marcus, mubiru]

jan_q1_kids.each do |kid|
  ChildCaseCycle.find_or_create_by!(child: kid,
                                    case_cycle: jan_q1_casecycle,
                                    subsidy_rule: sr_rule_1,
                                    part_days_allowed: 89,
                                    full_days_allowed: 89)
end

apr_q2_kids.each do |kid|
  ChildCaseCycle.find_or_create_by!(child: kid,
                                    case_cycle: apr_q2_casecycle,
                                    subsidy_rule: sr_rule_1,
                                    part_days_allowed: 90,
                                    full_days_allowed: 90)
end

# ---------------------------------------------
# Attendance
# ---------------------------------------------

puts ' Now creating attendance records...'

# @return [Array[Date]] - list of days, starting with the first date (inclusive),
#   ending with the last_date (inclusive),
#   and including random weekends dates (using the percent_weekends)
#   If skip_all_weekends, then absolutely no weekend dates are returned
def dates_skipping_most_weekends(first_date: Date.current - 60.days,
                                 last_date: Date.current,
                                 percent_on_weekends: 0.10,
                                 skip_all_weekends: false)
  dates = []
  num_days = last_date - first_date
  num_days.to_i.times do |day_num|
    this_date = (first_date + (day_num - 1)).to_datetime
    dates << this_date.to_date if this_date.on_weekday? || (!skip_all_weekends && Faker::Boolean.boolean(true_ratio: percent_on_weekends))
  end
  dates
end

RAND_CHECKIN_HRS_RANGE = 3 # checkin will be within 3 hours of the earliest checkin hour
RAND_CHECKOUT_HRS_RANGE = 18 # checkout will be within 18 hours of checkin

# create Attendance records, some random amount of part and full days.
def make_attendance(childsite,
                    childcasecycle,
                    first_date: Date.current - 10,
                    last_date: Date.current,
                    earliest_checkin_hour: 7)

  days_attended = dates_skipping_most_weekends(first_date: first_date, last_date: last_date)
  days_attended.each do |day_attended|
    random_checkin_time = (earliest_checkin_hour * 60) + Random.rand(60 * RAND_CHECKIN_HRS_RANGE).minutes
    random_checkout_time = random_checkin_time + Random.rand(60 * RAND_CHECKOUT_HRS_RANGE).minutes

    Attendance.find_or_create_by!(child_site: childsite,
                                  child_case_cycle: childcasecycle,
                                  starts_on: day_attended,
                                  check_in: day_attended + random_checkin_time,
                                  check_out: day_attended + random_checkout_time)
  end
end

def latest_date(date1, date2)
  [date1, date2].compact.max
end

# Attendance for Maria at the prairie_center between January 1 and March 31
maria_q1_casecycle = ChildCaseCycle.find_by(child: maria, case_cycle: jan_q1_casecycle)
start_date = latest_date(maria_at_prairie_ctr.started_care, JAN_1)
latest_date = latest_date(maria_at_prairie_ctr.ended_care, MAR_31)

make_attendance(maria_at_prairie_ctr,
                maria_q1_casecycle,
                first_date: start_date,
                last_date: latest_date,
                earliest_checkin_hour: 7)

# Attendance for K'Shawn at the prairie_center between January 1 and March 31
kshawn_q1_casecycle = ChildCaseCycle.find_by(child: maria, case_cycle: jan_q1_casecycle)
start_date = latest_date(kshawn_at_prairie_ctr.started_care, JAN_1)
latest_date = latest_date(kshawn_at_prairie_ctr.ended_care, MAR_31)
make_attendance(kshawn_at_prairie_ctr,
                kshawn_q1_casecycle,
                first_date: start_date,
                last_date: latest_date,
                earliest_checkin_hour: 7)

# ------------

# Attendance for Maria at the prairie_center between April 1 and June 30
maria_q1_casecycle = ChildCaseCycle.find_by(child: maria, case_cycle: jan_q1_casecycle)
start_date = latest_date(maria_at_prairie_ctr.started_care, APR_1)
latest_date = latest_date(maria_at_prairie_ctr.ended_care, JUN_30)
make_attendance(maria_at_prairie_ctr,
                maria_q1_casecycle,
                first_date: start_date,
                last_date: latest_date,
                earliest_checkin_hour: 7)

# Attendance for K'Shawn at the prairie_center between April 1 and June 30
kshawn_q1_casecycle = ChildCaseCycle.find_by(child: kshawn, case_cycle: apr_q2_casecycle)
start_date = latest_date(kshawn_at_prairie_ctr.started_care, APR_1)
latest_date = latest_date(kshawn_at_prairie_ctr.ended_care, JUN_30)
make_attendance(kshawn_at_prairie_ctr,
                kshawn_q1_casecycle,
                first_date: start_date,
                last_date: latest_date,
                earliest_checkin_hour: 7)

# Attendance for mubiru at the prairie_center between April 1 and June 30
mubiru_q1_casecycle = ChildCaseCycle.find_by(child: mubiru, case_cycle: apr_q2_casecycle)
start_date = latest_date(mubiru_at_prairie_ctr.started_care, APR_1)
latest_date = latest_date(mubiru_at_prairie_ctr.ended_care, JUN_30)
make_attendance(mubiru_at_prairie_ctr,
                mubiru_q1_casecycle,
                first_date: start_date,
                last_date: latest_date,
                earliest_checkin_hour: 7)

puts_records_in_db(Attendance)

# ---------------------------------------------

puts 'Seeding is done!'
