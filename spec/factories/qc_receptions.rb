# FactoryBot.define do
#   factory :qc_reception do
#     source { "MyString" }
#   end
# end


# # frozen_string_literal: true

# FactoryBot.define do

#   qc_results_list = [
#     {
#         "final_nano_drop": "200",
#         "final_nano_drop_230": "230",
#         "final_nano_drop_280": "280",
#         "post_spri_concentration": "10",
#         "post_spri_volume": "20",
#         "sheared_femto_fragment_size": "5",
#         "shearing_qc_comments": "Comments",
#         "date_required_by": "Long Read",
#         "date_submitted": "1689078551564.2458",
#         "labware_barcode": "FD20706500",
#         "priority_level": "Medium",
#         "reason_for_priority": "Reason goes here",
#         "sample_external_id": "supplier_sample_name_DDD",
#     },
#     {
#         "final_nano_drop": "100",
#         "final_nano_drop_230": "130",
#         "final_nano_drop_280": "180",
#         "post_spri_concentration": "10",
#         "post_spri_volume": "30",
#         "sheared_femto_fragment_size": "9",
#         "shearing_qc_comments": "Some comments",
#         "date_required_by": "Long Read",
#         "date_submitted": "1689078551564.2458",
#         "labware_barcode": "FD20706501",
#         "priority_level": "High",
#         "reason_for_priority": "Reason goes here",
#         "sample_external_id": "supplier_sample_name_DDD2",
#     },
# ]

#   factory :qc_reception do
#     source { 'tol-lab-share.tol' }
#     qc_results_list  qc_results_list
#     end
#   end

#   factory :qc_reception_resource_factory do
#     qc_reception
#   end
# end
