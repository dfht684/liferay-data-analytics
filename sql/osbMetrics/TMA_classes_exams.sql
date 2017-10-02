/*Table join scheme for class data*/
SELECT otco.name, otce.startDate, count(*) total,
  sum(case when otcu.status = "3" then 1 else 0 end) Three,
  sum(case when otcu.status = "2" then 1 else 0 end) Two,
  sum(case when otcu.status != ("2") and otcu.status != ("3") then 1 else 0 end) Not2_3
FROM osb_trainingevent otce
JOIN osb_trainingcustomer otcu
  ON otce.trainingEventId = otcu.classPK
JOIN osb_trainingcourse otco
  ON otce.trainingCourseId = otco.trainingCourseId
GROUP by year(otce.startDate)
ORDER by otce.startDate asc;
  
/*Table join scheme for exam data*/
SELECT cert.name, exr.startDate, count(*),
  sum(case when exr.grade = "3" then 1 else 0 end) passed,
  sum(case when exr.grade = 1 then 1 else 0 end) failed,
  sum(case when grade = "-1" then 1 else 0 end) NoTest
FROM osb_trainingExamResult exr
JOIN osb_trainingExam ex
  ON exr.trainingExamId = ex.trainingExamId
JOIN osb_trainingCertificateTemplate cert
  ON ex.trainingCertificateTemplateId = cert.trainingCertificateTemplateId
GROUP by cert.name, year(exr.startDate);
