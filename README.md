**API Management & Azure Open AI Terraform**
===========================
<span style="font-size: 12px">ver 2025.07.24</span>
<br>


***

### 변경 현황
|날짜|변경 내용|
|------|---|
|2025.07.15|1. terraform.tfvars 추가<br>2. Azure OpenAI 리소스 2개로 증가 (추가 확장 가능)<br>3. 관리ID 추가<br>4. APIM Policy를 Smart LB 방식으로 변경<br>6. api 방식을 OpenAPI 로 변경<br>7. APIM Backend 추가<br>8. APIM의 Public Network Access 및 VNET Integration 패치 추가|
|2025.07.24|1. AOAI 배포 시 신뢰하는 리소스 허용 옵션 해제 설정<br>2. APIM Subscription Key 자동 활성화<br>3. Application Insights 리소스 추가 및 APIM Logger로 연동<br>4. API Policy 수정|
|2025.08.05|1. APIM API 진단 설정 시 Custom Metric 설정 자동 활성화<br>2. AOAI Switch 관련 Named Value 및 Policy 내용 추가|

<br>

***

### 주요 내용
* 리소스의 이름 , 설정 등은 terraform.tfvars 에서 설정합니다. 
* 단, firewall policy 정책들은 locals.tf 에서 추가합니다.
* Azure OpenAI 리소스 추가 시 locals.tf 에서 aoai_backend 에 해당 리소스를 추가, ./modules/apim/policies/aoai_chat_policy.xml 파일에 backends.Add(new JObject() 룰 추가해주세요.
* APIM 의 Monitor 에서 Application Insights 에 등록된 Logger 를 통해 Application Insights 확인 가능
* 배포 전 반드시 terraform.tfvars 에서 APIM 및 AOAI 이름을 고유한 이름으로 수정 후 배포해주세요.
<br>

***

### 사전작업 
* <span style="font-size: 15px"> az login --tenant [Tenant ID] 를 입력해 배포할 구독의 Tenant 에 로그인 합니다. </span>
* <span style="font-size: 15px"> az account set --subscription [ subscription ID ] 를 입력해 배포할 구독의 ID 를 설정합니다. </span>
* <span style="font-size: 15px"> \$env:ARM_TENANT_ID = "Tenant ID" , \$env:ARM_SUBSCRIPTION_ID = "Subscription ID" 를 입력해 Terraform이 읽을 환경 변수를 등록합니다.</span>
<br>

***

### 사용방법
* <span style="font-size: 15px">terraform apply 시 Enter a value: 에 배포될 VM 의 Password 입력 .</span>
<br>

***