<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
  <head>
	<%@ include file="/WEB-INF/view/module/reporting/include.jsp"%>
	<%@ include file="/WEB-INF/view/module/reporting/includeScripts.jsp"%>
	<%@ include file="/WEB-INF/template/headerMinimal.jsp"%>
	<%@ include file="/WEB-INF/view/module/reporting/dialogSupport.jsp" %>
  </head>
  
<body>

<openmrs:require privilege="Run Reports" otherwise="/login.htm" redirect="/module/xreports/runReport.form" />

<script type="text/javascript">
var fixedValueElementIds = new Array();
var inputsToToggle = new Array();
jQuery(document).ready(
	function(){
		for( var i in fixedValueElementIds ){
			jQuery( "#" + fixedValueElementIds[ i ] ).addClass( fixedValueElementIds[ i ] );
		}
		for ( var i in inputsToToggle ) {
			toggleInputElements(inputsToToggle[i]);
		}
	}
);

function toggleInputElements( idPrefix ){
	jQuery( '.'+idPrefix ).toggle();
}
</script>

<style>
	.runTableCell {padding-right:10px; padding-bottom:5px;}
</style>

<div id="page">
	<div id="container">
		<div>
			<h1>${report.reportDefinition.name}</h1>
			<h2>${report.reportDefinition.description}</h2>
			
			<table style="width:100%;">
				<tr>
					<td>
	
						<fieldSet>
							<legend><b><spring:message code="reporting.runReport.runOrScheduleThisReport"/></b></legend>
			
							<spring:nestedPath path="report">
								<spring:bind path="reportDefinition">
									<c:if test="${not empty status.errorMessage}">
										<span class="error">${status.errorMessage}</span>
									</c:if>
								</spring:bind>
			
								<form method="post" action="fillParameter.form">
									<table style="padding:10px;">
										<c:forEach var="parameter" items="${report.reportDefinition.parameters}">
											<script type="text/javascript">
												fixedValueElementIds.push('userEnteredParam${parameter.name}');
											</script>
							                <tr>
							                    <spring:bind path="userEnteredParams[${parameter.name}]">
										            <td><spring:message code="${parameter.label}"/>:</td>
								                    <td>
						                   				<c:choose>
															<c:when test="${parameter.collectionType != null}">
																<wgt:widget id="userEnteredParam${parameter.name}" name="${status.expression}" type="${parameter.collectionType.name}" genericTypes="${parameter.type.name}" defaultValue="${status.value}" attributes="${parameter.widgetConfigurationAsString}"/>	
															</c:when>
															<c:otherwise>
																<wgt:widget id="userEnteredParam${parameter.name}" name="${status.expression}" type="${parameter.type.name}" defaultValue="${status.value}" attributes="${parameter.widgetConfigurationAsString}"/>	
																<c:if test="${fn:contains(expSupportedTypes, parameter.type.name)}">
																<spring:bind path="expressions[${parameter.name}]">
																<input class="userEnteredParam${parameter.name}" type="text" name="${status.expression}" value="${status.value}" style="display: none" /> 
																<span onclick="toggleInputElements('userEnteredParam${parameter.name}')">
																	<input class="userEnteredParam${parameter.name} smallButton" type="button" value='<spring:message code="reporting.Report.run.enterExpression"/>' style="width:100px;"/>
																	<input class="userEnteredParam${parameter.name} smallButton" type="button" value='<spring:message code="reporting.Report.run.enterFixedValue"/>' style="display:none; width:100px;" />
																</span>
																<c:if test="${not empty status.errorMessage}">
								                            		<span class="error">${status.errorMessage}</span>
								                        		</c:if>
																</spring:bind>
																</c:if>
															</c:otherwise>
														</c:choose>
								                        <c:if test="${not empty status.errorMessage}">
								                            <span class="error">${status.errorMessage}</span>
								                        </c:if>
								                        <c:if test="${fn:contains(inputsToToggle, parameter.name)}">
								                            <script type="text/javascript">
								                            	inputsToToggle.push('userEnteredParam${parameter.name}');
															</script>
								                        </c:if>	
								                    </td>
									            </spring:bind>
							                </tr>
							            </c:forEach>
										<tr>				
											<td><spring:message code="reporting.Report.run.outputFormat"/>:</td>					
											<td>
												<spring:bind path="selectedRenderer">
										            <select name="${status.expression}">
										                <c:forEach var="renderingMode" items="${report.renderingModes}">
										                	<c:set var="thisVal" value="${renderingMode.descriptor}"/>
										                    <option
										                        <c:if test="${status.value == thisVal}"> selected</c:if>
										                        value="${thisVal}">${renderingMode.label}
										                    </option>
										                </c:forEach>
										            </select>
													<c:if test="${not empty status.errorMessage}">
														<span class="error">${status.errorMessage}</span>
													</c:if>
												</spring:bind>
											</td>		
										</tr>
									</table>
									<table style="padding:10px;">
										<openmrs:globalProperty var="mode" key="reporting.runReportCohortFilterMode" defaultValue="showIfNull"/>
										<c:set var="showCohortFilter" value="${mode == 'hide' ? false : (mode == 'show' ? true : report.reportDefinition.baseCohortDefinition == null)}"/>
										<c:if test="${showCohortFilter}">
											<tr>
												<td class="runTableCell">
													<spring:message code="reporting.Report.run.runForSpecificCohort"/>
												</td>
												<td class="runTableCell">
													<spring:message code="reporting.Report.run.optionalFilterCohort" var="filterCohortLabel"/>
													<spring:message code="reporting.allPatients" var="allPatients"/>
													<rptTag:mappedPropertyForObject id="baseCohort" formFieldName="baseCohort" object="${report}" propertyName="baseCohort" label="${filterCohortLabel}" emptyValueLabel="${allPatients}"/>
									          	</td>
									         </tr>
										</c:if>
						        		<tr valign="top">
							                <td class="runTableCell"><spring:message code="reporting.Report.run.whenShouldReportBeRun"/></td>
							                <td class="runTableCell">
							                	<spring:bind path="schedule">
							                		<rptTag:cronExpressionField id="runReport" formFieldName="${status.expression}" formFieldValue="${status.value}"/>
										       		<c:if test="${not empty status.errorMessage}">
														<span class="error">${status.errorMessage}</span>
													</c:if>
										        </spring:bind>
							                </td>
							            </tr>
							            <tr>
							            	<td colspan="2">
							            		<br/>
							            		<input type="hidden" name="reportId" value="${report.reportDefinition.uuid}" />
												<input type="submit" value="<spring:message code="reporting.Report.run.button"/>" />
												<c:if test="${!empty report.existingRequestUuid}">
													<span style="padding-left:20px;">
														<a onclick="return confirm('<spring:message code="reporting.reportHistory.confirmDelete"/>');" href="../reports/deleteReportRequest.form?uuid=${report.existingRequestUuid}">
															<button border="0"><spring:message code="general.delete"/></button>
														</a>
													</span>
												</c:if>
							        		</td>
							        	</tr>
							        </table>
								</form>
							</spring:nestedPath>
							
						</fieldSet>
					</td>
				</tr>
			</table>
		</div>
	</div>
</div>
</body>
</html>